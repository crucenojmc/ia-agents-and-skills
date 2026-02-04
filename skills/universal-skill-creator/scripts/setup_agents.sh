#!/bin/bash
#
# AI Skills Setup Script
# ======================
# Configures AI coding assistants to use the skills in this repository.
# 
# Supported AI Assistants:
#   - Claude Code (Anthropic)
#   - Gemini CLI (Google Antigravity)
#   - Codex (OpenAI)
#   - GitHub Copilot
#
# Usage:
#   ./setup.sh                    # Interactive mode
#   ./setup.sh --all              # Configure all assistants
#   ./setup.sh --claude --gemini  # Configure specific assistants
#   ./setup.sh --help             # Show help
#
# Based on the setup pattern from prowler-cloud/prowler
#

set -e

# Get script and repository paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
SKILLS_SOURCE="$SCRIPT_DIR/skills"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Selection flags
SETUP_CLAUDE=false
SETUP_GEMINI=false
SETUP_CODEX=false
SETUP_COPILOT=false
SETUP_GLOBAL=false
USE_SYMLINKS=true
FORCE_OVERWRITE=false

# =============================================================================
# HELP AND MENU FUNCTIONS
# =============================================================================

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Configure AI coding assistants to use skills from this repository."
    echo ""
    echo "Options:"
    echo "  --all       Configure all AI assistants"
    echo "  --claude    Configure Claude Code"
    echo "  --gemini    Configure Gemini CLI (Antigravity)"
    echo "  --codex     Configure Codex (OpenAI)"
    echo "  --copilot   Configure GitHub Copilot"
    echo "  --global    Also install to global locations (~/.gemini, ~/.claude)"
    echo "  --copy      Copy files instead of creating symlinks"
    echo "  --help      Show this help message"
    echo ""
    echo "If no options provided, runs in interactive mode."
    echo ""
    echo "Examples:"
    echo "  $0                      # Interactive selection"
    echo "  $0 --all                # All AI assistants"
    echo "  $0 --claude --gemini    # Only Claude and Gemini"
    echo "  $0 --all --global       # All assistants + global installation"
    echo ""
    echo "Locations configured:"
    echo "  Claude:   .claude/skills/, CLAUDE.md"
    echo "  Gemini:   .gemini/skills/, GEMINI.md (also .agent/skills/)"
    echo "  Codex:    .codex/skills/, AGENTS.md (native)"
    echo "  Copilot:  .github/skills/, .github/copilot-instructions.md"
    echo ""
    echo "Global locations (with --global):"
    echo "  Claude:   ~/.claude/skills/"
    echo "  Gemini:   ~/.gemini/antigravity/skills/"
    echo "  Copilot:  ~/.copilot/skills/"
}

show_menu() {
    echo -e "${BOLD}Which AI assistants do you want to configure?${NC}"
    echo -e "${CYAN}(Use numbers to toggle, Enter to confirm)${NC}"
    echo ""

    local options=("Claude Code" "Gemini CLI (Google)" "Codex (OpenAI)" "GitHub Copilot" "Global Install (~/.claude, ~/.gemini)")
    local selected=(true true false true false)  # Claude, Gemini, Copilot selected by default

    while true; do
        for i in "${!options[@]}"; do
            if [ "${selected[$i]}" = true ]; then
                echo -e "  ${GREEN}[x]${NC} $((i+1)). ${options[$i]}"
            else
                echo -e "  [ ] $((i+1)). ${options[$i]}"
            fi
        done
    echo -e "  ${YELLOW}a${NC}. Select all"
        echo -e "  ${YELLOW}n${NC}. Select none"
        echo ""
        echo -n "Toggle (1-5, a, n) or Enter to confirm: "

        read -r choice

        case $choice in
            1) selected[0]=$([ "${selected[0]}" = true ] && echo false || echo true) ;;
            2) selected[1]=$([ "${selected[1]}" = true ] && echo false || echo true) ;;
            3) selected[2]=$([ "${selected[2]}" = true ] && echo false || echo true) ;;
            4) selected[3]=$([ "${selected[3]}" = true ] && echo false || echo true) ;;
            5) selected[4]=$([ "${selected[4]}" = true ] && echo false || echo true) ;;
            a|A) selected=(true true true true true) ;;
            n|N) selected=(false false false false false) ;;
            "") break ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac

        # Move cursor up to redraw menu
        echo -en "\033[12A\033[J"
    done

    SETUP_CLAUDE=${selected[0]}
    SETUP_GEMINI=${selected[1]}
    SETUP_CODEX=${selected[2]}
    SETUP_COPILOT=${selected[3]}
    SETUP_GLOBAL=${selected[4]}
    
    # Check if global is selected, ask for advanced mode
    if [ "$SETUP_GLOBAL" = true ]; then
        echo -e "${BOLD}Global Installation Mode:${NC}"
        echo "1. Install ALL skills to default locations (Standard)"
        echo "2. Select specific skills and destination (Advanced)"
        echo -n "Choose (1/2): "
        read -r global_mode
        if [ "$global_mode" = "2" ]; then
            CONFIGURE_GLOBAL_INTERACTIVE=true
        fi
    fi
}

configure_global_interactive() {
    echo ""
    echo -e "${BOLD}${BLUE}🌍 Advanced Global Skill Installation${NC}"
    echo "========================================"
    
    # 1. Select Skills
    echo -e "${BOLD}Select skills to install globally:${NC}"
    local available_skills=($(find "$SKILLS_SOURCE" -maxdepth 2 -name "SKILL.md" -exec dirname {} \; | xargs -I {} basename {}))
    local selected_skills=()
    local skill_status=()
    
    # Initialize all to false initially
    for i in "${!available_skills[@]}"; do skill_status+=(false); done
    
    while true; do
        for i in "${!available_skills[@]}"; do
            if [ "${skill_status[$i]}" = true ]; then
                echo -e "  ${GREEN}[x]${NC} $((i+1)). ${available_skills[$i]}"
            else
                echo -e "  [ ] $((i+1)). ${available_skills[$i]}"
            fi
        done
        echo ""
        echo -e "  ${YELLOW}a${NC}. Select all"
        echo -e "  ${YELLOW}n${NC}. Select none"
        echo -e "  ${GREEN}Enter${NC}. Confirm selection"
        echo ""
        echo -n "Toggle (1-${#available_skills[@]}, a, n) or Enter: "
        read -r choice
        
        if [ -z "$choice" ]; then break; fi
        
        case $choice in
            a|A) for i in "${!skill_status[@]}"; do skill_status[$i]=true; done ;;
            n|N) for i in "${!skill_status[@]}"; do skill_status[$i]=false; done ;;
            *) 
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#available_skills[@]}" ] && [ "$choice" -gt 0 ]; then
                    idx=$((choice-1))
                    skill_status[$idx]=$([ "${skill_status[$idx]}" = true ] && echo false || echo true)
                fi
                ;;
        esac
        # Redraw lines
        count=${#available_skills[@]}
        lines=$((count + 5))
        echo -en "\033[${lines}A\033[J"
    done

    # 2. Select Destination Provider
    echo ""
    echo -e "${BOLD}Select primary global location:${NC}"
    echo "1. Claude (~/.claude/skills)"
    echo "2. Gemini (~/.gemini/antigravity/skills)"
    echo "3. Copilot (~/.copilot/skills)"
    echo -n "Choose (1-3): "
    read -r provider_choice
    
    local target_base=""
    case $provider_choice in
        1) target_base="$HOME/.claude/skills" ;;
        2) target_base="$HOME/.gemini/antigravity/skills" ;;
        3) target_base="$HOME/.copilot/skills" ;;
        *) echo "${RED}Invalid choice. Skipping global install.${NC}"; return ;;
    esac
    
    echo ""
    echo -e "${YELLOW}Installing selected skills to $target_base...${NC}"
    mkdir -p "$target_base"
    
    for i in "${!available_skills[@]}"; do
        if [ "${skill_status[$i]}" = true ]; then
            skill="${available_skills[$i]}"
            echo -e "  Installing ${BOLD}$skill${NC}"
            
            # COPY the skill folder (not symlink) for true portability
            local src="$SKILLS_SOURCE/$skill"
            local dest="$target_base/$skill"
            
            if [ -d "$dest" ]; then
                rm -rf "$dest"
            fi
            cp -r "$src" "$dest"
            echo -e "  ${GREEN}✓ Copied to global${NC}"
        fi
    done
    
    # Disable standard global setup since we handled it manually
    SETUP_GLOBAL=false
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

create_link_or_copy() {
    local source="$1"
    local target="$2"
    local description="$3"

    # Remove existing target
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -d "$target" ]; then
        mv "$target" "${target}.backup.$(date +%s)"
        echo -e "${YELLOW}    Backed up existing directory${NC}"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create symlink or copy
    if [ "$USE_SYMLINKS" = true ]; then
        ln -s "$source" "$target"
        echo -e "${GREEN}  ✓ $description (symlink)${NC}"
    else
        cp -r "$source" "$target"
        echo -e "${GREEN}  ✓ $description (copied)${NC}"
    fi
}

copy_agents_md() {
    local target_name="$1"
    local target_dir="$2"
    
    if [ -f "$REPO_ROOT/AGENTS.md" ]; then
        cp "$REPO_ROOT/AGENTS.md" "$target_dir/$target_name"
        echo -e "${GREEN}  ✓ AGENTS.md -> $target_dir/$target_name${NC}"
    fi
}

# =============================================================================
# SETUP FUNCTIONS
# =============================================================================

setup_claude() {
    local target="$REPO_ROOT/.claude/skills"
    
    mkdir -p "$REPO_ROOT/.claude"
    create_link_or_copy "$SKILLS_SOURCE" "$target" ".claude/skills -> skills/"
    
    # Symlink CLAUDE.md -> AGENTS.md
    local config_target="$REPO_ROOT/.claude/CLAUDE.md"
    if [ -f "$REPO_ROOT/AGENTS.md" ]; then
        if [ -L "$config_target" ] || [ -f "$config_target" ]; then rm "$config_target"; fi
        ln -s "../AGENTS.md" "$config_target"
        echo -e "${GREEN}  ✓ CLAUDE.md -> AGENTS.md (symlink)${NC}"
    fi
}

# Helper for global installation (MERGE strategy)
install_skills_individually() {
    local source_dir="$1"
    local target_dir="$2"
    local context="$3"
    local mode="$4" # "copy" or "link"
    
    mkdir -p "$(dirname "$target_dir")"
    
    # SAFETY CHECK: Remove symlink parent if exists
    if [ -L "$target_dir" ]; then
        echo -e "${YELLOW}  ⚠ Correcting global target: $target_dir is a symlink. Removing it...${NC}"
        rm "$target_dir"
    fi
    
    mkdir -p "$target_dir"
    echo -e "  Target: $target_dir"
    
    # Iterate over valid skills
    find "$source_dir" -maxdepth 2 -name "SKILL.md" -exec dirname {} \; | xargs -I {} basename {} | while read skill; do
        local src_skill="$source_dir/$skill"
        local dest_skill="$target_dir/$skill"
        local proceed=true
        
        # Check collision
        if [ -d "$dest_skill" ] || [ -L "$dest_skill" ]; then
            if [ "$mode" == "copy" ]; then
                local do_overwrite=false
                
                if [ "$FORCE_OVERWRITE" = true ]; then
                    do_overwrite=true
                else
                    # Interactive confirmation for Overwrite in global
                    echo -n "    ❓ Skill '${BOLD}$skill${NC}' already exists. Overwrite? [y/N]: "
                    read -r answer
                    if [[ "$answer" =~ ^[Yy]$ ]]; then
                        do_overwrite=true
                    fi
                fi
                
                if [ "$do_overwrite" = true ]; then
                     # Backup before overwrite
                    mv "$dest_skill" "${dest_skill}.backup.$(date +%s)"
                    echo -e "${YELLOW}       Backed up previous version${NC}"
                else
                    echo -e "       Skipped."
                    proceed=false
                fi
            else
                # For symlinks (project level), usually just update
                rm "$dest_skill" 2>/dev/null || rm -rf "$dest_skill"
            fi
        fi
        
        if [ "$proceed" = true ]; then
            if [ "$mode" == "copy" ]; then
                cp -r "$src_skill" "$dest_skill"
                echo -e "${GREEN}    ✓ Copied: $skill${NC}"
            else
                ln -s "$src_skill" "$dest_skill"
                echo -e "${GREEN}    ✓ Linked: $skill${NC}"
            fi
        fi
    done
}

setup_claude_global() {
    local target="$HOME/.claude/skills"
    # Use individual installation to safely merge with existing skills
    install_skills_individually "$SKILLS_SOURCE" "$target" "Claude (Global)" "copy"
}

setup_gemini() {
    # .gemini/skills (for Gemini CLI)
    local target="$REPO_ROOT/.gemini/skills"
    mkdir -p "$REPO_ROOT/.gemini"
    create_link_or_copy "$SKILLS_SOURCE" "$target" ".gemini/skills -> skills/"
    
    # Symlink GEMINI.md -> AGENTS.md
    local config_target="$REPO_ROOT/.gemini/GEMINI.md"
    if [ -f "$REPO_ROOT/AGENTS.md" ]; then
        if [ -L "$config_target" ] || [ -f "$config_target" ]; then rm "$config_target"; fi
        ln -s "../AGENTS.md" "$config_target"
        echo -e "${GREEN}  ✓ GEMINI.md -> AGENTS.md (symlink)${NC}"
    fi
    
    # Also create .agent/skills (for Antigravity IDE)
    local agent_target="$REPO_ROOT/.agent/skills"
    mkdir -p "$REPO_ROOT/.agent"
    create_link_or_copy "$SKILLS_SOURCE" "$agent_target" ".agent/skills -> skills/"
}

setup_codex() {
    local target="$REPO_ROOT/.codex/skills"
    
    mkdir -p "$REPO_ROOT/.codex"
    create_link_or_copy "$SKILLS_SOURCE" "$target" ".codex/skills -> skills/"
    echo -e "${GREEN}  ✓ Codex uses AGENTS.md natively${NC}"
}

setup_copilot() {
    # GitHub Copilot supports skills in .github/skills/ (official structure)
    # Reference: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
    
    mkdir -p "$REPO_ROOT/.github"
    
    # Create symlink to skills in .github/skills/
    local target="$REPO_ROOT/.github/skills"
    create_link_or_copy "$SKILLS_SOURCE" "$target" ".github/skills -> skills/"
    
    # Create symlink for copilot-instructions.md pointing to AGENTS.md
    # This ensures AGENTS.md is the single source of truth
    local instructions_target="$REPO_ROOT/.github/copilot-instructions.md"
    
    if [ -f "$REPO_ROOT/AGENTS.md" ]; then
        # Remove existing file/link if it exists
        if [ -L "$instructions_target" ]; then
            rm "$instructions_target"
        elif [ -f "$instructions_target" ]; then
            rm "$instructions_target"
        fi
        
        # Create symlink relative to .github/
        # AGENTS.md is in root, so path is ../AGENTS.md
        ln -s "../AGENTS.md" "$instructions_target"
        echo -e "${GREEN}  ✓ copilot-instructions.md -> AGENTS.md (symlink)${NC}"
    fi
}

setup_gemini_global() {
    local target="$HOME/.gemini/antigravity/skills"
    # Use individual installation to safely merge with existing skills
    install_skills_individually "$SKILLS_SOURCE" "$target" "Gemini (Global)" "copy"
}

setup_copilot_global() {
    local target="$HOME/.copilot/skills"
    # Use individual installation to safely merge with existing skills
    install_skills_individually "$SKILLS_SOURCE" "$target" "Copilot (Global)" "copy"
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            SETUP_CLAUDE=true
            SETUP_GEMINI=true
            SETUP_CODEX=true
            SETUP_COPILOT=true
            shift
            ;;
        --claude)
            SETUP_CLAUDE=true
            shift
            ;;
        --gemini)
            SETUP_GEMINI=true
            shift
            ;;
        --codex)
            SETUP_CODEX=true
            shift
            ;;
        --copilot)
            SETUP_COPILOT=true
            shift
            ;;
        --global)
            SETUP_GLOBAL=true
            shift
            ;;
        --copy)
            USE_SYMLINKS=false
            shift
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# =============================================================================
# Header
echo ""
echo -e "${BOLD}${MAGENTA}🤖 AI Skills Setup${NC}"
echo "===================="
echo ""
echo -e "${BLUE}Repository: ${NC}$REPO_ROOT"
echo ""

# Count skills
SKILL_COUNT=$(find "$SKILLS_SOURCE" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$SKILL_COUNT" -eq 0 ]; then
    echo -e "${RED}No skills found in $SKILLS_SOURCE${NC}"
    echo "Make sure the skills/ directory contains skill folders with SKILL.md files."
    exit 1
fi

echo -e "${CYAN}Found $SKILL_COUNT skill(s) to configure:${NC}"
find "$SKILLS_SOURCE" -maxdepth 2 -name "SKILL.md" -exec dirname {} \; | xargs -I {} basename {} | while read skill; do
    echo "  • $skill"
done
echo ""

# Interactive mode if no flags provided
if [ "$SETUP_CLAUDE" = false ] && [ "$SETUP_GEMINI" = false ] && [ "$SETUP_CODEX" = false ] && [ "$SETUP_COPILOT" = false ]; then
    show_menu
    echo ""
fi

# Check if at least one selected
if [ "$SETUP_CLAUDE" = false ] && [ "$SETUP_GEMINI" = false ] && [ "$SETUP_CODEX" = false ] && [ "$SETUP_COPILOT" = false ]; then
    echo -e "${YELLOW}No AI assistants selected. Nothing to do.${NC}"
    exit 0
fi

# Calculate steps
STEP=1
TOTAL=0
[ "$SETUP_CLAUDE" = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_GEMINI" = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_CODEX" = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_COPILOT" = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_GLOBAL" = true ] && [ "$SETUP_CLAUDE" = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_GLOBAL" = true ] && [ "$SETUP_GEMINI" = true ] && TOTAL=$((TOTAL + 1))
[ "$SETUP_GLOBAL" = true ] && [ "$SETUP_COPILOT" = true ] && TOTAL=$((TOTAL + 1))

# Check if interactive global configuration is needed
if [ "$CONFIGURE_GLOBAL_INTERACTIVE" = true ]; then
    configure_global_interactive
fi

echo -e "${BOLD}Setting up AI assistants...${NC}"
echo ""

# Run setups
if [ "$SETUP_CLAUDE" = true ]; then
    echo -e "${YELLOW}[$STEP/$TOTAL] Claude Code (project)${NC}"
    setup_claude
    STEP=$((STEP + 1))
fi

if [ "$SETUP_GLOBAL" = true ] && [ "$SETUP_CLAUDE" = true ]; then
    echo -e "${YELLOW}[$STEP/$TOTAL] Claude Code (global)${NC}"
    setup_claude_global
    STEP=$((STEP + 1))
fi

if [ "$SETUP_GEMINI" = true ]; then
    echo -e "${YELLOW}[$STEP/$TOTAL] Gemini CLI / Antigravity (project)${NC}"
    setup_gemini
    STEP=$((STEP + 1))
fi

if [ "$SETUP_GLOBAL" = true ] && [ "$SETUP_GEMINI" = true ]; then
    echo -e "${YELLOW}[$STEP/$TOTAL] Gemini CLI (global)${NC}"
    setup_gemini_global
    STEP=$((STEP + 1))
fi

if [ "$SETUP_CODEX" = true ]; then
    echo -e "${YELLOW}[$STEP/$TOTAL] Codex (OpenAI)${NC}"
    setup_codex
    STEP=$((STEP + 1))
fi

if [ "$SETUP_COPILOT" = true ]; then
    echo -e "${YELLOW}[$STEP/$TOTAL] GitHub Copilot (project)${NC}"
    setup_copilot
    STEP=$((STEP + 1))
fi

if [ "$SETUP_GLOBAL" = true ] && [ "$SETUP_COPILOT" = true ]; then
    echo -e "${YELLOW}[$STEP/$TOTAL] GitHub Copilot (global)${NC}"
    setup_copilot_global
    STEP=$((STEP + 1))
fi

# =============================================================================
# Summary
echo ""
echo -e "${GREEN}${BOLD}✅ Successfully configured $SKILL_COUNT AI skill(s)!${NC}"
echo ""
echo "Configured locations:"
[ "$SETUP_CLAUDE" = true ] && echo "  • Claude Code:    .claude/skills/ + .claude/CLAUDE.md"
[ "$SETUP_GEMINI" = true ] && echo "  • Gemini CLI:     .gemini/skills/ + .gemini/GEMINI.md"
[ "$SETUP_GEMINI" = true ] && echo "  • Antigravity:    .agent/skills/"
[ "$SETUP_CODEX" = true ] && echo "  • Codex (OpenAI): .codex/skills/ + AGENTS.md (native)"
[ "$SETUP_COPILOT" = true ] && echo "  • GitHub Copilot: .github/skills/ + .github/copilot-instructions.md"
[ "$SETUP_GLOBAL" = true ] && [ "$SETUP_CLAUDE" = true ] && echo "  • Claude (global):  ~/.claude/skills/"
[ "$SETUP_GLOBAL" = true ] && [ "$SETUP_GEMINI" = true ] && echo "  • Gemini (global):  ~/.gemini/antigravity/skills/"
[ "$SETUP_GLOBAL" = true ] && [ "$SETUP_COPILOT" = true ] && echo "  • Copilot (global): ~/.copilot/skills/"
echo ""
echo -e "${BLUE}Notes:${NC}"
echo "  • Restart your AI assistant to load the skills"
echo "  • AGENTS.md is the source of truth - edit it, then re-run this script"
echo "  • For Gemini CLI, enable experimental.skills in settings"
echo ""
echo -e "${CYAN}Skills available:${NC}"
find "$SKILLS_SOURCE" -maxdepth 2 -name "SKILL.md" -exec dirname {} \; | xargs -I {} basename {} | while read skill; do
    desc=$(grep -A2 "^description:" "$SKILLS_SOURCE/$skill/SKILL.md" 2>/dev/null | head -2 | tail -1 | sed 's/^[ ]*//' | head -c 60)
    echo "  • $skill: $desc..."
done
echo ""
