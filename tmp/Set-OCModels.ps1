#requires -Version 5.1
<#
.SYNOPSIS
  Sets OpenCode agent models across the project + global opencode.jsonc files.

.DESCRIPTION
  Updates the `model` field of:
    - manager            (1)
    - 7 leads            (project-plan-lead, clean-code-lead, testing-lead,
                          security-lead, seo-lead, decision-intelligence-lead,
                          github-operations-lead)
    - 35 workers         (pp-worker-1..6, cc-worker + cc-worker-1..6,
                          test-worker-1..6, sec-worker-1..6, seo-worker-1..6,
                          github-git-worker, github-pr-worker,
                          github-actions-worker, github-release-worker,
                          jev-worker)
  in BOTH:
    - the project file   <PROJECT_ROOT>\.opencode\opencode.jsonc
    - the global file    %USERPROFILE%\.config\opencode\opencode.jsonc

  The script is idempotent: it reads current values, shows the planned diff,
  asks for confirmation, then writes backups + updates atomically.

.PARAMETER Scope
  all      -> update both files (default)
  project  -> update the project file only
  global   -> update the global file only

.PARAMETER Manager
  New model ID for `manager`. Defaults to the current global value.

.PARAMETER Leads
  New model ID for all 7 leads. Defaults to the current global value.

.PARAMETER Workers
  New model ID for all 35 workers. Defaults to the current global value.

.PARAMETER Preset
  Optional preset name. Recognized presets:
    - "default"      -> current global values (no change)
    - "workers-m3"   -> workers = MiniMax-M3#thinking, leaders untouched
    - "all-m3"       -> all three groups on MiniMax-M3#thinking
    - "all-gpt5"     -> sol/terra/luna from current global values
  Any CLI parameter overrides the preset.

.EXAMPLE
  pwsh .\tmp\Set-OCModels.ps1 -Preset workers-m3
  Switches every worker to MiniMax-M3#thinking in both files.

.EXAMPLE
  pwsh .\tmp\Set-OCModels.ps1 -Workers 'openai/gpt-5-mini' -Scope project
  Only updates the project file. Workers to gpt-5-mini. Manager + leads untouched.

.EXAMPLE
  pwsh .\tmp\Set-OCModels.ps1 -Manager 'openai/gpt-5.6-sol' -Leads 'openai/gpt-5.6-terra' -Workers 'minimax-coding-plan/MiniMax-M3#thinking' -Scope all
  Fully explicit change across both files.

.EXAMPLE
  pwsh .\tmp\Set-OCModels.ps1 -Interactive
  Walk through every change interactively. Pick providers and models from a
  numbered list, choose which agent or agent group to apply them to.

.PARAMETER Interactive
  Switch to an interactive picker. Lists providers/models from `opencode models`,
  lets you choose the target agents, and applies the change in the same flow.
#>

[CmdletBinding()]
param(
  [ValidateSet('all','project','global')]
  [string]$Scope = 'all',

  [switch]$Interactive,

  [string]$Manager,
  [string]$Leads,
  [string]$Workers,

  [ValidateSet('default','workers-m3','all-m3','all-gpt5')]
  [string]$Preset = 'default',

  [switch]$Yes    # skip confirmation prompt
)

$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------ interactive picker -----
# Catalog file with provider/model IDs and variants. If present, we use it
# instead of `opencode models` (which doesn't print anything when its TUI
# isn't attached). The catalog is small (~7 KB) and lives in the OpenCode
# cache directory.
$global:CatalogPath = Join-Path $HOME '.config\opencode\cache\models-catalog.json'

# Returns an array of objects {Id, Provider, Model, Variants} either from the
# cached catalog or by parsing the text `opencode models` prints.
function Get-AvailableModels {
  $models = New-Object System.Collections.Generic.List[object]
  $source = ''
  if (Test-Path -LiteralPath $global:CatalogPath) {
    try {
      $catalog = Get-Content -LiteralPath $global:CatalogPath -Raw | ConvertFrom-Json -ErrorAction Stop
      foreach ($prov in $catalog.providers) {
        foreach ($m in $prov.models) {
          $parts = $m.id -split '/'
          [void]$models.Add([pscustomobject]@{
            Id       = $m.id
            Provider = $parts[0]
            Model    = $parts[1]
            Variants = @($m.variants)
          })
        }
      }
      $source = 'catalog'
    } catch {
      Write-Host "WARN: catalog unreadable, falling back to `opencode models`: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
  }
  if ($models.Count -eq 0) {
    $raw = opencode models 2>&1 | Out-String
    foreach ($line in ($raw -split "`r?`n")) {
      $trim = $line.Trim()
      if ($trim -match '^[A-Za-z][A-Za-z0-9_\-]*/[A-Za-z0-9_\-\.:]+$') {
        $parts = $trim -split '/'
        [void]$models.Add([pscustomobject]@{
          Id       = $trim
          Provider = $parts[0]
          Model    = $parts[1]
          Variants = @()
        })
      }
    }
    $source = 'opencode models'
  }
  Write-Host ("Loaded {0} model(s) from {1}." -f $models.Count, $source) -ForegroundColor DarkGray
  return $models
}

function Pick-Provider {
  param([object[]]$Models)
  $providers = @($Models | ForEach-Object Provider | Sort-Object -Unique)
  Write-Host ""
  Write-Host "Available providers:" -ForegroundColor Cyan
  for ($i=0; $i -lt $providers.Count; $i++) {
    $count = (@($Models | Where-Object Provider -eq $providers[$i])).Count
    Write-Host ("  [{0,2}] {1,-25} ({2} model(s))" -f ($i+1), $providers[$i], $count)
  }
  Write-Host "  [ *] all providers"
  while ($true) {
    $choice = (Read-Host "Provider number, name fragment, '*' for all, or 'q' to quit").Trim()
    if ($choice -eq 'q') { return $null }
    if ($choice -eq '*') { return '*' }
    if ($choice -match '^\d+$' -and $choice -ge 1 -and $choice -le $providers.Count) {
      return $providers[$choice - 1]
    }
    # Treat as a substring match against provider names
    $lower = $choice.ToLowerInvariant()
    $matches = @($providers | Where-Object { $_.ToLowerInvariant().Contains($lower) })
    if ($matches.Count -eq 1) { return $matches[0] }
    if ($matches.Count -gt 1) {
      Write-Host ("  '{0}' matches multiple: {1}" -f $choice, ($matches -join ', ')) -ForegroundColor DarkYellow
      Write-Host "  Type a more specific fragment or a number." -ForegroundColor DarkYellow
      continue
    }
    Write-Host "  No provider matched. Try a number or a substring." -ForegroundColor Red
  }
}

function Pick-Model {
  param([object[]]$Candidates,[string]$Label,[string]$CurrentModel)
  if ($Candidates.Count -eq 0) {
    Write-Host "  No models matched." -ForegroundColor Red
    return $null
  }
  Write-Host ""
  Write-Host ("$Label - {0} candidate(s):" -f $Candidates.Count) -ForegroundColor Cyan
  if ($CurrentModel) {
    $curIdx = -1
    for ($i=0; $i -lt $Candidates.Count; $i++) {
      if ($Candidates[$i].Id -eq $CurrentModel -or $Candidates[$i].Model -eq ($CurrentModel -split '/')[-1]) {
        $curIdx = $i; break
      }
    }
    if ($curIdx -ge 0) {
      Write-Host ("  Current: {0}  (number {1})" -f $CurrentModel, ($curIdx + 1)) -ForegroundColor DarkYellow
    } else {
      Write-Host ("  Current: {0}  (not in this filter)" -f $CurrentModel) -ForegroundColor DarkYellow
    }
  }
  $shown = [Math]::Min($Candidates.Count, 30)
  for ($i=0; $i -lt $shown; $i++) {
    Write-Host ("  [{0,3}] {1}" -f ($i+1), $Candidates[$i].Id)
  }
  if ($Candidates.Count -gt $shown) {
    Write-Host ("  ... {0} more. Type a search term to filter." -f ($Candidates.Count - $shown)) -ForegroundColor DarkGray
  }
  while ($true) {
    $raw = (Read-Host "Model number, search text, or 'b' to go back").Trim()
    if ($raw -eq 'b') { return $null }
    if ($raw -eq 'q') { return 'quit' }
    if ($raw -match '^\d+$') {
      $n = [int]$raw
      if ($n -ge 1 -and $n -le $Candidates.Count) {
        $selected = $Candidates[$n - 1].Id
        return (Resolve-ModelVariant -Model $selected -CurrentModel $CurrentModel)
      }
      Write-Host "  Out of range." -ForegroundColor Red
      continue
    }
    # Treat as a search substring
    $lower = $raw.ToLowerInvariant()
    $filtered = @($Candidates | Where-Object { $_.Id.ToLowerInvariant().Contains($lower) })
    if ($filtered.Count -eq 0) {
      Write-Host "  No matches." -ForegroundColor Red
      continue
    }
    if ($filtered.Count -eq 1) {
      $selected = $filtered[0].Id
      return (Resolve-ModelVariant -Model $selected -CurrentModel $CurrentModel)
    }
    Write-Host ""
    Write-Host ("Filter '{0}' -> {1} match(es):" -f $raw, $filtered.Count) -ForegroundColor Cyan
    for ($i=0; $i -lt $filtered.Count; $i++) {
      Write-Host ("  [{0,3}] {1}" -f ($i+1), $filtered[$i].Id)
    }
    while ($true) {
      $pick = (Read-Host "Pick a number (or 'b' to retry search)").Trim()
      if ($pick -eq 'b') { break }
      if ($pick -match '^\d+$' -and $pick -ge 1 -and $pick -le $filtered.Count) {
        $selected = $filtered[$pick - 1].Id
        return (Resolve-ModelVariant -Model $selected -CurrentModel $CurrentModel)
      }
      Write-Host "  Invalid." -ForegroundColor Red
    }
  }
}

# If the current model uses a variant suffix (#thinking, etc.) and the new
# model is the same base, offer to keep it. Otherwise return the new model
# verbatim so the user can re-type a variant later if they want one.
function Resolve-ModelVariant {
  param([string]$Model,[string]$CurrentModel)
  if (-not $CurrentModel) { return $Model }
  if ($CurrentModel -match '^(.+)#([A-Za-z0-9_\-]+)$') {
    $curVariant = $Matches[2]
    $curBase    = $Matches[1]
    if ($curBase -eq $Model) {
      $ans = Read-Host "Keep current variant '#$curVariant' on the new model? [Y/n]"
      if ($ans -in '','Y','y','yes','YES') {
        return ($Model + '#' + $curVariant)
      }
      return $Model
    }
  }
  return $Model
}

function Pick-AgentGroup {
  # Returns one of: 'manager', 'leads', 'workers', or $null for back.
  Write-Host ""
  Write-Host "Which group?" -ForegroundColor Cyan
  Write-Host "  [1] manager   (1 agent)"
  Write-Host "  [2] leads     (7 agents)"
  Write-Host "  [3] workers   (35 agents)"
  Write-Host "  [4] custom    (pick individual agents)"
  Write-Host "  [q] quit"
  while ($true) {
    $choice = (Read-Host "Group").Trim()
    switch ($choice) {
      '1' { return 'manager' }
      '2' { return 'leads' }
      '3' { return 'workers' }
      '4' { return 'custom' }
      'q' { return $null }
      default { Write-Host "  Invalid." -ForegroundColor Red }
    }
  }
}

function Pick-CustomAgents {
  $all = @($ManagerName) + $LeadNames + $WorkerNames
  Write-Host ""
  Write-Host "Pick individual agents (comma- or space-separated numbers, or 'all'):" -ForegroundColor Cyan
  for ($i=0; $i -lt $all.Count; $i++) {
    $role = if ($all[$i] -eq 'manager') { 'mgr ' } elseif ($LeadNames -contains $all[$i]) { 'lead' } else { 'work' }
    Write-Host ("  [{0,3}] ({1}) {2}" -f ($i+1), $role, $all[$i])
  }
  while ($true) {
    $raw = (Read-Host "Numbers (e.g. 1,3,5 or 9-12)").Trim()
    if ($raw -eq 'q') { return $null }
    if ($raw -eq 'all') { return $all }
    $picks = New-Object System.Collections.Generic.List[string]
    $tokens = $raw -split '[\s,]+'
    $ok = $true
    foreach ($t in $tokens) {
      if ($t -match '^(\d+)-(\d+)$') {
        $from = [int]$Matches[1]; $to = [int]$Matches[2]
        for ($n=$from; $n -le $to; $n++) {
          if ($n -lt 1 -or $n -gt $all.Count) { $ok = $false; break }
          [void]$picks.Add($all[$n - 1])
        }
      } elseif ($t -match '^\d+$') {
        $n = [int]$t
        if ($n -lt 1 -or $n -gt $all.Count) { $ok = $false; break }
        [void]$picks.Add($all[$n - 1])
      } else {
        $ok = $false
      }
    }
    if ($ok -and $picks.Count -gt 0) { return $picks.ToArray() }
    Write-Host "  Invalid selection." -ForegroundColor Red
  }
}

function Invoke-InteractivePicker {
  # Nested menus:
  #   1) Pick agent group (manager/leads/workers)
  #   2) Pick agents within that group (all by default, or specific indices)
  #   3) Pick provider
  #   4) Pick model
  #   Apply immediately. Return to step 1 until the user quits.
  Write-Host "Loading model catalog..." -ForegroundColor DarkGray
  $allModels = @(Get-AvailableModels)
  if ($allModels.Count -eq 0) {
    Write-Host "ERROR: no models available. Check the catalog file." -ForegroundColor Red
    return
  }
  Write-Host ("Loaded {0} model(s) from {1} provider(s)." -f $allModels.Count, (@($allModels.Provider | Sort-Object -Unique).Count)) -ForegroundColor DarkGray
  Write-Host ""

  $files = @(Resolve-Files -Scope $Scope)

  while ($true) {
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "  AGENT GROUPS" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "  [1] manager   (1 agent)"
    Write-Host "  [2] leads     (7 agents)"
    Write-Host "  [3] workers   (35 agents)"
    Write-Host "  [q] quit"
    Write-Host ""
    $groupChoice = (Read-Host "Group").Trim().ToLowerInvariant()
    if ($groupChoice -eq 'q') { break }
    if ($groupChoice -notin '1','2','3') {
      Write-Host "  Invalid." -ForegroundColor Red
      continue
    }

    # Build the agent list for this group, with current models.
    $groupLabel = switch ($groupChoice) {
      '1' { 'manager' }
      '2' { 'leads' }
      '3' { 'workers' }
    }
    $groupAgents = switch ($groupChoice) {
      '1' { @($ManagerName) }
      '2' { @($LeadNames) }
      '3' { @($WorkerNames) }
    }

    # Sub-menu: pick agents within the group.
    Write-Host ""
    Write-Host "----------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host ("  {0} ({1} agent(s))" -f $groupLabel.ToUpperInvariant(), $groupAgents.Count) -ForegroundColor DarkCyan
    Write-Host "----------------------------------------------------------------" -ForegroundColor DarkCyan
    $curModels = @{}
    for ($i=0; $i -lt $groupAgents.Count; $i++) {
      $a = $groupAgents[$i]
      $cm = $null
      if ($files.Count -gt 0) { $cm = Get-CurrentModel -File $files[0] -AgentName $a }
      $curModels[$a] = $cm
      $cmDisplay = if ($cm) { $cm } else { '(unknown)' }
      Write-Host ("  [{0,2}] {1,-32}  current: {2}" -f ($i+1), $a, $cmDisplay)
    }
    Write-Host "  [all] apply to every agent in this group (default if you press Enter)"
    Write-Host "  [b] back to group menu"
    Write-Host ""
    $selRaw = (Read-Host "Agents (e.g. 1,3,5 or 9-12, or 'all')").Trim().ToLowerInvariant()
    if ($selRaw -eq 'b') { continue }
    $picks = New-Object System.Collections.Generic.List[string]
    if ($selRaw -eq '' -or $selRaw -eq 'all') {
      foreach ($a in $groupAgents) { [void]$picks.Add($a) }
    } else {
      $ok = $true
      foreach ($t in ($selRaw -split '[\s,]+')) {
        if ($t -match '^(\d+)-(\d+)$') {
          $from = [int]$Matches[1]; $to = [int]$Matches[2]
          if ($from -gt $to -or $from -lt 1 -or $to -gt $groupAgents.Count) { $ok = $false; break }
          for ($n=$from; $n -le $to; $n++) { [void]$picks.Add($groupAgents[$n - 1]) }
        } elseif ($t -match '^\d+$') {
          $n = [int]$t
          if ($n -lt 1 -or $n -gt $groupAgents.Count) { $ok = $false; break }
          [void]$picks.Add($groupAgents[$n - 1])
        } else {
          $ok = $false; break
        }
      }
      if (-not $ok -or $picks.Count -eq 0) {
        Write-Host "  Invalid selection." -ForegroundColor Red
        continue
      }
    }
    $targetAgents = @($picks | Select-Object -Unique)
    $sampleModel = $curModels[$targetAgents[0]]

    # Sub-menu: pick provider.
    Write-Host ""
    Write-Host "----------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  PROVIDERS" -ForegroundColor DarkCyan
    Write-Host "----------------------------------------------------------------" -ForegroundColor DarkCyan
    $providers = @($allModels | ForEach-Object Provider | Sort-Object -Unique)
    for ($i=0; $i -lt $providers.Count; $i++) {
      $count = (@($allModels | Where-Object Provider -eq $providers[$i])).Count
      Write-Host ("  [{0,2}] {1,-25} ({2} model(s))" -f ($i+1), $providers[$i], $count)
    }
    Write-Host "  [ *] all providers"
    Write-Host "  [b] back"
    Write-Host ""
    $provChoice = (Read-Host "Provider number, name fragment, '*' for all, or 'b' to go back").Trim().ToLowerInvariant()
    if ($provChoice -eq 'b') { continue }
    $pickedProvider = $null
    if ($provChoice -eq '*') {
      $pickedProvider = '*'
    } elseif ($provChoice -match '^\d+$' -and $provChoice -ge 1 -and $provChoice -le $providers.Count) {
      $pickedProvider = $providers[$provChoice - 1]
    } else {
      $matches = @($providers | Where-Object { $_.ToLowerInvariant().Contains($provChoice) })
      if ($matches.Count -eq 1) { $pickedProvider = $matches[0] }
      elseif ($matches.Count -gt 1) {
        Write-Host ("  '{0}' matches multiple: {1}" -f $provChoice, ($matches -join ', ')) -ForegroundColor DarkYellow
        continue
      } else {
        Write-Host "  No provider matched." -ForegroundColor Red
        continue
      }
    }
    $candidates = if ($pickedProvider -eq '*') { $allModels } else { @($allModels | Where-Object Provider -eq $pickedProvider) }

    # Sub-menu: pick model within provider.
    Write-Host ""
    Write-Host "----------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host ("  MODELS in '{0}' ({1} candidate(s))" -f $pickedProvider, $candidates.Count) -ForegroundColor DarkCyan
    Write-Host "----------------------------------------------------------------" -ForegroundColor DarkCyan
    if ($sampleModel) {
      Write-Host ("  Current sample: {0}" -f $sampleModel) -ForegroundColor DarkYellow
    }
    $shown = [Math]::Min($candidates.Count, 25)
    for ($i=0; $i -lt $shown; $i++) {
      $v = $candidates[$i].Variants
      $vStr = ''
      if ($v -and $v.Count -gt 0) {
        $vStr = '  (variants: ' + ($v -join ', ') + ')'
      }
      Write-Host ("  [{0,3}] {1}{2}" -f ($i+1), $candidates[$i].Id, $vStr)
    }
    if ($candidates.Count -gt $shown) {
      Write-Host ("  ... and {0} more. Type a search term to filter, or 'b' to go back." -f ($candidates.Count - $shown)) -ForegroundColor DarkGray
    }
    Write-Host ""
    $modelRaw = (Read-Host "Model number, search text, or 'b' to go back").Trim()
    if ($modelRaw -eq 'b') { continue }
    if ($modelRaw -eq '') { Write-Host "  Empty selection." -ForegroundColor Red; continue }

    $selectedModel = $null
    if ($modelRaw -match '^\d+$') {
      $n = [int]$modelRaw
      if ($n -ge 1 -and $n -le $candidates.Count) {
        $selectedModel = $candidates[$n - 1].Id
      } else {
        Write-Host "  Out of range." -ForegroundColor Red; continue
      }
    } else {
      $lower = $modelRaw.ToLowerInvariant()
      $filtered = @($candidates | Where-Object { $_.Id.ToLowerInvariant().Contains($lower) })
      if ($filtered.Count -eq 0) {
        Write-Host "  No matches." -ForegroundColor Red; continue
      } elseif ($filtered.Count -eq 1) {
        $selectedModel = $filtered[0].Id
      } else {
        Write-Host ""
        Write-Host ("  Filter '{0}' -> {1} match(es):" -f $modelRaw, $filtered.Count) -ForegroundColor DarkCyan
        for ($i=0; $i -lt $filtered.Count; $i++) {
          Write-Host ("    [{0,3}] {1}" -f ($i+1), $filtered[$i].Id)
        }
        $pick = (Read-Host "Pick a number (or 'b' to retry)").Trim()
        if ($pick -eq 'b') { continue }
        if ($pick -match '^\d+$' -and $pick -ge 1 -and $pick -le $filtered.Count) {
          $selectedModel = $filtered[$pick - 1].Id
        } else {
          Write-Host "  Invalid." -ForegroundColor Red; continue
        }
      }
    }

    # Optional variant confirmation if sample has one.
    if ($sampleModel -and $sampleModel -match '^(.+)#([A-Za-z0-9_\-]+)$') {
      $curVariant = $Matches[2]
      $curBase    = $Matches[1]
      if ($curBase -eq $selectedModel) {
        $ans = Read-Host "Keep current variant '#$curVariant' on the new model? [Y/n]"
        if ($ans -in '','Y','y','yes','YES') {
          $selectedModel = ($selectedModel + '#' + $curVariant)
        }
      }
    }

    # APPLY IMMEDIATELY.
    Apply-AgentModelChange -Files $files -AgentNames $targetAgents -NewModel $selectedModel
  }

  Write-Host ""
  Write-Host "Exited interactive picker." -ForegroundColor Yellow
  $script:interactiveDone = $true
}

# Apply model change directly to a list of agents across the target files.
# Each file gets its own backup. JSON validity is verified; rollback on failure.
function Apply-AgentModelChange {
  param(
    [object[]]$Files,
    [string[]]$AgentNames,
    [string]$NewModel
  )
  foreach ($f in $Files) {
    # Build a plan for this file
    $rows = New-Object System.Collections.Generic.List[object]
    foreach ($a in $AgentNames) {
      $cur = Get-CurrentModel -File $f -AgentName $a
      if ($null -ne $cur -and $cur -ne $NewModel) {
        $rows.Add([pscustomobject]@{ Agent = $a; Old = $cur; New = $NewModel })
      }
    }
    if ($rows.Count -eq 0) { continue }

    # Backup
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $bk = "$f.backup-$stamp"
    Copy-Item -LiteralPath $f -Destination $bk -Force

    # Apply
    $lines = Get-Content -LiteralPath $f
    $changed = 0
    $expectModel = $false
    $targetAgent = $null
    $targetOld   = $null
    $targetNew   = $null
    for ($i=0; $i -lt $lines.Count; $i++) {
      $line = $lines[$i]
      if (-not $expectModel) {
        $hit = $false
        foreach ($r in $rows) {
          $aEsc = [regex]::Escape($r.Agent)
          $oldEsc = [regex]::Escape($r.Old)
          # Inline form on the same line: "agent": { "model": "OLD", ...
          # Split the line around the OLD value to preserve the trailing text.
          $nameMarker = '"{0}"\s*:\s*\{{\s*"model"\s*:\s*"' -f $aEsc
          if ($line -match $nameMarker) {
            $idx = [regex]::Match($line, $nameMarker)
            if ($idx.Success) {
              $valStart = $idx.Index + $idx.Length
              $endIdx   = $line.IndexOf('"', $valStart)
              if ($endIdx -gt $valStart) {
                $currentVal = $line.Substring($valStart, $endIdx - $valStart)
                if ($currentVal -eq $r.Old) {
                  $before = $line.Substring(0, $valStart)
                  $after  = $line.Substring($endIdx)
                  $lines[$i] = $before + $r.New + $after
                  $changed++
                  $hit = $true
                  break
                }
              }
            }
          }
          if ($hit) { break }
          # Multi-line form: "agent": {  (model on next line)
          if ($line -match ('^\s*"{0}"\s*:\s*\{{' -f $aEsc)) {
            $targetAgent = $r.Agent
            $targetOld   = $r.Old
            $targetNew   = $r.New
            $expectModel = $true
            $hit = $true
            break
          }
        }
      } else {
        # Find "model": "OLD" on this line and split around it.
        $oldEsc = [regex]::Escape($targetOld)
        $marker = '"model"\s*:\s*"'
        $idx = [regex]::Match($line, $marker)
        if ($idx.Success) {
          $valStart = $idx.Index + $idx.Length
          $endIdx   = $line.IndexOf('"', $valStart)
          if ($endIdx -gt $valStart) {
            $currentVal = $line.Substring($valStart, $endIdx - $valStart)
            if ($currentVal -eq $targetOld) {
              $before = $line.Substring(0, $valStart)
              $after  = $line.Substring($endIdx)
              $lines[$i] = $before + $targetNew + $after
              $changed++
              $expectModel = $false
              $targetAgent = $null
              $targetOld   = $null
              $targetNew   = $null
            }
          }
        } elseif ($line -match '^\s*\}') {
          $expectModel = $false
          $targetAgent = $null
          $targetOld   = $null
          $targetNew   = $null
        }
      }
    }
    Set-Content -LiteralPath $f -Value $lines -Encoding UTF8

    # Verify JSON
    try {
      $raw = Get-Content -LiteralPath $f -Raw
      $stripped = ($raw -split "`r?`n" | Where-Object { $_ -notmatch '^\s*//' }) -join "`n"
      $null = $stripped | ConvertFrom-Json -ErrorAction Stop
    } catch {
      Copy-Item -LiteralPath $bk -Destination $f -Force
      Write-Host "  ERROR: JSON broken after edit of $f. Restored backup. $($_.Exception.Message)" -ForegroundColor Red
      continue
    }

    # Feedback
    Write-Host ""
    Write-Host ("  Applied to {0}:" -f $f) -ForegroundColor Green
    foreach ($r in $rows) {
      if ($r.Agent -in @($AgentNames)) { # all that we attempted
        Write-Host ("    {0,-32}  {1}  ->  {2}" -f $r.Agent, $r.Old, $r.New) -ForegroundColor DarkCyan
      }
    }
    Write-Host ("  {0} change(s) committed. Backup: {1}" -f $changed, (Split-Path -Leaf $bk)) -ForegroundColor DarkGray
  }
  Write-Host ""
  Write-Host "  >>> Returning to agent groups. Press Ctrl+C to exit at any time." -ForegroundColor Yellow
}



# ------------------------------------------------------------ paths -----
$globalDir  = Join-Path $HOME '.config\opencode'
$globalFile = Join-Path $globalDir 'opencode.jsonc'

# Find the project file by walking up from the current working directory.
# We look for the nearest `.opencode\opencode.jsonc` (the project's own file).
# The script location is NOT a reliable source: the wrapper at
# ~/.config/opencode/Set-OCModels.ps1 is far from any project root.
function Find-ProjectFile {
  $dir = (Get-Location).Path
  while ($true) {
    $candidate = Join-Path $dir '.opencode\opencode.jsonc'
    if (Test-Path -LiteralPath $candidate) { return $candidate }
    $parent = Split-Path -Parent $dir
    if ($parent -eq $dir -or [string]::IsNullOrEmpty($parent)) { return $null }
    $dir = $parent
  }
}
$projFile = Find-ProjectFile

function Resolve-Files {
  param([string]$Scope)
  $list = New-Object System.Collections.Generic.List[string]
  if ($Scope -in 'all','project') {
    if (-not $projFile) {
      throw "Project file not found: no .opencode\opencode.jsonc in the current directory or any parent. Use -Scope global to update only the global file."
    }
    if (-not (Test-Path -LiteralPath $projFile)) {
      throw "Project file not found: $projFile"
    }
    [void]$list.Add($projFile)
  }
  if ($Scope -in 'all','global') {
    if (-not (Test-Path -LiteralPath $globalFile)) {
      throw "Global file not found: $globalFile"
    }
    [void]$list.Add($globalFile)
  }
  return $list
}

# ------------------------------------------------------------ registry of agents -----
$ManagerName  = 'manager'
$LeadNames    = @(
  'project-plan-lead','clean-code-lead','testing-lead','security-lead',
  'seo-lead','decision-intelligence-lead','github-operations-lead'
)
$WorkerNames  = @(
  'pp-worker-1','pp-worker-2','pp-worker-3','pp-worker-4','pp-worker-5','pp-worker-6',
  'cc-worker','cc-worker-1','cc-worker-2','cc-worker-3','cc-worker-4','cc-worker-5','cc-worker-6',
  'test-worker-1','test-worker-2','test-worker-3','test-worker-4','test-worker-5','test-worker-6',
  'sec-worker-1','sec-worker-2','sec-worker-3','sec-worker-4','sec-worker-5','sec-worker-6',
  'seo-worker-1','seo-worker-2','seo-worker-3','seo-worker-4','seo-worker-5','seo-worker-6',
  'github-git-worker','github-pr-worker','github-actions-worker','github-release-worker',
  'jev-worker'
)

# ------------------------------------------------------------ read current models -----
function Get-CurrentModel {
  param([string]$File,[string]$AgentName)
  $lines = Get-Content -LiteralPath $File
  $namePattern = '^\s*"' + [regex]::Escape($AgentName) + '"\s*:\s*\{'
  $modelInline = '"' + [regex]::Escape($AgentName) + '"\s*:\s*\{\s*"model"\s*:\s*"([^"]+)"'
  $modelOnNext  = '^\s*"model"\s*:\s*"([^"]+)"'
  $expectModel = $false
  for ($i=0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    # Case 1: agent name + "model" on same line
    if ($line -match $modelInline) {
      return $Matches[1]
    }
    # Case 2: agent name on its own line, model on the next
    if (-not $expectModel) {
      if ($line -match $namePattern) { $expectModel = $true; continue }
    } else {
      if ($line -match $modelOnNext) {
        return $Matches[1]
      }
      # If a closing brace arrives before "model", the agent block has no model
      if ($line -match '^\s*\}') { return $null }
    }
  }
  return $null
}

# ------------------------------------------------------------ dashboard -----
# Read every agent in the file and bucket them by model. For each group
# (manager / leads / workers) summarise: if all share one model, print that
# model; if mixed, list each distinct model with the agents on it.
function Get-AgentState {
  param([string]$File)
  $state = @{
    'manager' = @{ Agents = @(); Model = $null }
    'leads'   = @{ Agents = @(); Model = $null }
    'workers' = @{ Agents = @(); Model = $null }
  }
  if (-not (Test-Path -LiteralPath $File)) { return $state }
  if ($state['manager'].Agents.Count -eq 0) {
    $state['manager'].Agents = @(@{ Name = 'manager'; Model = (Get-CurrentModel -File $File -AgentName 'manager') })
  }
  foreach ($a in $LeadNames) {
    $state['leads'].Agents += ,@{ Name = $a; Model = (Get-CurrentModel -File $File -AgentName $a) }
  }
  foreach ($a in $WorkerNames) {
    $state['workers'].Agents += ,@{ Name = $a; Model = (Get-CurrentModel -File $File -AgentName $a) }
  }
  return $state
}

function Format-GroupSummary {
  param([hashtable]$Bucket)
  $agents = @($Bucket.Agents)
  $nonNull = @($agents | Where-Object { $_.Model })
  if ($nonNull.Count -eq 0) { return '(no model)' }
  $uniqueModels = @($nonNull | ForEach-Object Model | Sort-Object -Unique)
  if ($uniqueModels.Count -eq 1) {
    return ("{0}  (all {1} agents match)" -f $uniqueModels[0], $nonNull.Count)
  }
  $lines = @()
  foreach ($m in $uniqueModels) {
    $list = @($agents | Where-Object { $_.Model -eq $m })
    $names = ($list | ForEach-Object Name) -join ', '
    $lines += ("  - {0}  ({1} agent(s)): {2}" -f $m, $list.Count, $names)
  }
  return ($lines -join "`n")
}

function Show-Dashboard {
  # Decide which files to display.
  $displayFiles = New-Object System.Collections.Generic.List[object]
  if ($Scope -in 'all','project' -and $projFile -and (Test-Path -LiteralPath $projFile)) {
    $displayFiles.Add(@{ Path = $projFile; Label = 'PROJECT' })
  }
  if ($Scope -in 'all','global' -and (Test-Path -LiteralPath $globalFile)) {
    $displayFiles.Add(@{ Path = $globalFile; Label = 'GLOBAL' })
  }
  if ($displayFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor DarkGray
    Write-Host "  No files in scope to summarise." -ForegroundColor DarkGray
    Write-Host "================================================================" -ForegroundColor DarkGray
    return
  }

  Write-Host ""
  foreach ($f in $displayFiles) {
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ("  {0}  ({1})" -f $f.Label, $f.Path) -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    $state = Get-AgentState -File $f.Path

    foreach ($group in @('manager','leads','workers')) {
      $label = $group.ToUpperInvariant()
      $bucket = $state[$group]
      $agents = @($bucket.Agents)
      $nullCount = @($agents | Where-Object { -not $_.Model }).Count
      $summary = Format-GroupSummary -Bucket $bucket
      if ($group -eq 'manager') {
        # Always show manager on a single line, including its name.
        $m = ($agents | Where-Object Name -eq 'manager').Model
        if ($m) {
          Write-Host ("  manager : {0}" -f $m)
        } else {
          Write-Host "  manager : (no model)" -ForegroundColor Red
        }
        continue
      }
      $count = $agents.Count
      Write-Host ("  {0,-8} ({1} agents):" -f $label, $count)
      # If summary is one line (all share a model) it stays on one line;
      # if multi-model, summary contains newlines for each variant.
      $summaryLines = $summary -split "`n"
      foreach ($sl in $summaryLines) {
        if ($sl.StartsWith('  - ')) {
          Write-Host ("    {0}" -f $sl.TrimStart())
        } else {
          Write-Host ("    {0}" -f $sl)
        }
      }
      if ($nullCount -gt 0) {
        Write-Host ("    (!) {0} agent(s) have no model assigned" -f $nullCount) -ForegroundColor DarkYellow
      }
    }
    Write-Host ""
  }
}

# ------------------------------------------------------------ preset resolution -----
$globalHas = Test-Path -LiteralPath $globalFile
if (-not $globalHas) {
  throw "Global file missing: $globalFile. Run `opencode debug config` once first."
}

# Read the global file once to discover its current values.
$curGlobalManager = Get-CurrentModel -File $globalFile -AgentName $ManagerName
$curGlobalLeads   = Get-CurrentModel -File $globalFile -AgentName $LeadNames[0]
$curGlobalWorkers = Get-CurrentModel -File $globalFile -AgentName $WorkerNames[0]
if (-not $curGlobalManager -or -not $curGlobalLeads -or -not $curGlobalWorkers) {
  throw "Could not read current models from $globalFile. File structure may be unusual."
}

# Show the current state of every agent up-front.
Show-Dashboard

# Run interactive picker if requested. It applies changes directly and
# returns only when the user quits the picker.
$interactiveDone = $false
if ($Interactive) {
  Invoke-InteractivePicker
  # The interactive picker applies changes itself. Exit cleanly regardless
  # of whether the user staged any change before quitting.
  return
}

# Default behavior: do nothing unless the user explicitly chose a preset
# or passed Manager/Leads/Workers parameters.
$cliProvided = $PSBoundParameters.ContainsKey('Manager') `
            -or $PSBoundParameters.ContainsKey('Leads') `
            -or $PSBoundParameters.ContainsKey('Workers') `
            -or $skipPresetLogic

# Mark which groups are being explicitly targeted. Anything not targeted
# will be left untouched in every file (no cross-file replacement).
$TargetManager = $false
$TargetLeads   = $false
$TargetWorkers = $false

if (-not $cliProvided -and $Preset -eq 'default') {
  Write-Host ""
  Write-Host "Nothing to do. Pass -Manager/-Leads/-Workers, or use -Preset <workers-m3|all-m3|all-gpt5>." -ForegroundColor Yellow
  Write-Host "Examples:"
  Write-Host "  pwsh .\tmp\Set-OCModels.ps1 -Preset workers-m3"
  Write-Host "  pwsh .\tmp\Set-OCModels.ps1 -Workers 'openai/gpt-5-mini' -Yes"
  Write-Host "  pwsh .\tmp\Set-OCModels.ps1 -Manager 'openai/gpt-5.6-sol' -Leads 'openai/gpt-5.6-terra' -Workers 'minimax-coding-plan/MiniMax-M3#thinking' -Yes"
  return
}

switch ($Preset) {
  'default'    { }                                  # CLI values below
  'workers-m3' { $TargetWorkers = $true; $Workers = 'minimax-coding-plan/MiniMax-M3#thinking' }
  'all-m3'     { $TargetManager = $true; $TargetLeads = $true; $TargetWorkers = $true
                  $Manager = 'minimax-coding-plan/MiniMax-M3#thinking'
                  $Leads   = 'minimax-coding-plan/MiniMax-M3#thinking'
                  $Workers = 'minimax-coding-plan/MiniMax-M3#thinking' }
  'all-gpt5'   { $TargetManager = $true; $TargetLeads = $true; $TargetWorkers = $true
                  $Manager = $curGlobalManager
                  $Leads   = $curGlobalLeads
                  $Workers = $curGlobalWorkers }
}

if ($PSBoundParameters.ContainsKey('Manager')) { $TargetManager = $true }
if ($PSBoundParameters.ContainsKey('Leads'))   { $TargetLeads   = $true }
if ($PSBoundParameters.ContainsKey('Workers')) { $TargetWorkers = $true }

# Interactive mode sets these via $script: variables; mirror them into the
# local targets so the rest of the script treats them as CLI-provided.
if ($skipPresetLogic) {
  if ($Manager -and $Manager -ne $curGlobalManager) { $TargetManager = $true }
  if ($Leads   -and $Leads   -ne $curGlobalLeads)   { $TargetLeads   = $true }
  if ($Workers -and $Workers -ne $curGlobalWorkers) { $TargetWorkers = $true }
}

# ------------------------------------------------------------ preview -----
$files = Resolve-Files -Scope $Scope
Write-Host ""
Write-Host "=== OpenCode model update ===" -ForegroundColor Cyan
Write-Host ("Scope: {0}" -f $Scope)
if ($TargetManager) { Write-Host ("Manager:    {0}" -f $Manager) } else { Write-Host "Manager:    (unchanged)" }
if ($TargetLeads)   { Write-Host ("Leads:      {0}" -f $Leads)   } else { Write-Host "Leads:      (unchanged)" }
if ($TargetWorkers) { Write-Host ("Workers:    {0}" -f $Workers) } else { Write-Host "Workers:    (unchanged)" }
Write-Host ""
Write-Host "Planned diff per file:" -ForegroundColor Cyan

# In interactive mode we already built a per-agent plan inside the picker.
# Skip the group-level rebuild to keep partial selections intact.
if ($skipPresetLogic) {
  $plan = $script:plan
  # Display the per-file diff from the interactive plan
  foreach ($f in $files) {
    $rows = $plan | Where-Object File -eq $f
    if ($rows) {
      Write-Host ""
      Write-Host ("--- {0} ---" -f $f) -ForegroundColor Yellow
      foreach ($r in $rows) {
        Write-Host ("  {0,-32}  {1}  ->  {2}" -f $r.Agent, $r.Old, $r.New) -ForegroundColor DarkYellow
      }
    }
  }
} else {
  $plan = @() # rows: [File, Agent, Old, New]
  foreach ($f in $files) {
  $fileHasDiff = $false
  $rows = New-Object System.Collections.Generic.List[object]
  foreach ($a in @($ManagerName) + $LeadNames + $WorkerNames) {
    $cur = Get-CurrentModel -File $f -AgentName $a
    if ($null -eq $cur) { continue }
    $isTarget = $false
    $newVal = $null
    if ($a -eq $ManagerName) {
      $isTarget = $TargetManager; $newVal = $Manager
    } elseif ($LeadNames -contains $a) {
      $isTarget = $TargetLeads;   $newVal = $Leads
    } else {
      $isTarget = $TargetWorkers; $newVal = $Workers
    }
    if ($isTarget -and $cur -ne $newVal) {
      $rows.Add([pscustomobject]@{ Agent=$a; Old=$cur; New=$newVal })
      $fileHasDiff = $true
    }
  }
  if ($fileHasDiff) {
    Write-Host ""
    Write-Host ("--- {0} ---" -f $f) -ForegroundColor Yellow
    foreach ($r in $rows) {
      $plan += [pscustomobject]@{ File=$f; Agent=$r.Agent; Old=$r.Old; New=$r.New }
      Write-Host ("  {0,-32}  {1}  ->  {2}" -f $r.Agent, $r.Old, $r.New) -ForegroundColor DarkYellow
    }
  }
  } # end if !skipPresetLogic
}

if ($plan.Count -eq 0) {
  Write-Host ""
  Write-Host "No changes needed. Everything already matches." -ForegroundColor Green
  return
}

# ------------------------------------------------------------ confirm -----
if (-not $Yes) {
  Write-Host ""
  $ans = Read-Host "Apply $($plan.Count) change(s) across $($files.Count) file(s)? [Y/n]"
  if ($ans -notin '','Y','y','yes','YES') {
    Write-Host "Aborted." -ForegroundColor Red
    return
  }
}

# ------------------------------------------------------------ apply -----
function Replace-ModelInline {
  param([string]$Line,[string]$AgentName,[string]$OldModel,[string]$NewModel)
  # "agent": { "model": "OLD", ...   ->   "agent": { "model": "NEW", ...
  # The OLD model string must be replaced verbatim, preserving everything else.
  $aEsc = [regex]::Escape($AgentName)
  $oEsc = [regex]::Escape($OldModel)
  # Two capture groups: (before-old-model) (old-model) (after-old-model)
  # We need THREE pieces: before, the old string, and after. So we capture
  # the substring before, the literal OLD, and the substring after.
  $pattern = '(^\s*"' + $aEsc + '"\s*:\s*\{\s*"model"\s*:\s*")' + $oEsc + '(")'
  if ($Line -match $pattern) {
    # $Matches[1] = everything up to and including the opening quote of old model value
    # $Matches[2] = the closing quote of old model value
    # The rest of the line after $Matches[2] is preserved by returning Matches[1]+New+Matches[2]+rest
    $restStart = $pattern.Length - 2  # adjust; we know how much was consumed
    # Simpler approach: find the position of the old model value and split
    $oldPattern = '"\s*' + $oEsc + '\s*"'
    $matchIdx = [regex]::Match($Line, $oldPattern)
    if ($matchIdx.Success) {
      $before = $Line.Substring(0, $matchIdx.Index)
      $afterStart = $matchIdx.Index + $matchIdx.Length
      $after = $Line.Substring($afterStart)
      return ($before + '"' + $NewModel + '"' + $after)
    }
  }
  return $null
}

function Replace-ModelNextLine {
  param([string]$Line,[string]$OldModel,[string]$NewModel)
  # "model": "OLD",  ->  "model": "NEW",
  $oEsc = [regex]::Escape($OldModel)
  $pattern = '"\s*' + $oEsc + '\s*"'
  $matchIdx = [regex]::Match($Line, $pattern)
  if ($matchIdx.Success) {
    $before = $Line.Substring(0, $matchIdx.Index)
    $afterStart = $matchIdx.Index + $matchIdx.Length
    $after = $Line.Substring($afterStart)
    return ($before + '"' + $NewModel + '"' + $after)
  }
  return $null
}

foreach ($f in $files) {
  # 1) backup
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $bk = "$f.backup-$stamp"
  Copy-Item -LiteralPath $f -Destination $bk -Force

  # 2) update
  $lines = Get-Content -LiteralPath $f
  $changed = 0
  $expectModel = $false
  $targetAgent = $null
  $targetOld   = $null
  $targetNew   = $null
  for ($i=0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if (-not $expectModel) {
      foreach ($a in $plan | Where-Object File -eq $f) {
        $replaced = Replace-ModelInline -Line $line -AgentName $a.Agent -OldModel $a.Old -NewModel $a.New
        if ($null -ne $replaced) {
          $lines[$i] = $replaced
          $changed++
          break
        }
        $aEsc = [regex]::Escape($a.Agent)
        if ($line -match ('^\s*"{0}"\s*:\s*\{{' -f $aEsc)) {
          $targetAgent = $a.Agent
          $targetOld   = $a.Old
          $targetNew   = $a.New
          $expectModel = $true
          break
        }
      }
    } else {
      $replaced = Replace-ModelNextLine -Line $line -OldModel $targetOld -NewModel $targetNew
      if ($null -ne $replaced) {
        $lines[$i] = $replaced
        $changed++
        $expectModel = $false
        $targetAgent = $null
        $targetOld   = $null
        $targetNew   = $null
      } elseif ($line -match '^\s*\}') {
        $expectModel = $false
        $targetAgent = $null
        $targetOld   = $null
        $targetNew   = $null
      }
    }
  }
  Set-Content -LiteralPath $f -Value $lines -Encoding UTF8

  # 3) verify JSON
  try {
    $raw = Get-Content -LiteralPath $f -Raw
    $stripped = ($raw -split "`r?`n" | Where-Object { $_ -notmatch '^\s*//' }) -join "`n"
    $null = $stripped | ConvertFrom-Json -ErrorAction Stop
  } catch {
    # ROLLBACK: copy backup back over the broken file
    Copy-Item -LiteralPath $bk -Destination $f -Force
    throw "JSON broken after edit of $f. Restored backup $bk. Error: $($_.Exception.Message)"
  }
  Write-Host ("OK  {0}  ({1} change(s), backup: {2})" -f $f, $changed, (Split-Path -Leaf $bk)) -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Restart OpenCode to pick up the new models." -ForegroundColor Cyan
