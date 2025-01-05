#!/bin/bash

# Configuration
NEW_NAME="priyanshu Harshbodhi"
NEW_EMAIL="priyanshuqpwp@gmail.com"
START_DATE="2025-01-01"
END_DATE="2025-03-31"

REPO_DIR="/home/priyanshu/repos/new-p/CascadeProjects/3D Solar System Simulator"

cd "$REPO_DIR" || exit 1

# Ensure we have the backup
if ! git rev-parse backup-before-rewrite >/dev/null 2>&1; then
    echo "Backup branch not found. Creating from current HEAD (assuming it's original enough or has been backed up)."
    git branch backup-before-rewrite main
fi

# Get all commits from original history
commits=$(git rev-list --reverse backup-before-rewrite)
num_commits=$(echo "$commits" | wc -l)

echo "Found $num_commits commits in original history."

start_ts=$(date -d "$START_DATE" +%s)
end_ts=$(date -d "$END_DATE" +%s)
interval=$(( (end_ts - start_ts) / (num_commits + 1) ))

# Create a new branch starting from scratch
git checkout --orphan super-clean-rewrite
git rm -rf .

# Important: set these globally for the session
export GIT_AUTHOR_NAME="$NEW_NAME"
export GIT_AUTHOR_EMAIL="$NEW_EMAIL"
export GIT_COMMITTER_NAME="$NEW_NAME"
export GIT_COMMITTER_EMAIL="$NEW_EMAIL"

i=0
for commit in $commits; do
    i=$((i + 1))
    
    commit_ts=$((start_ts + i * interval))
    commit_date=$(date -d "@$commit_ts" --rfc-3339=seconds)
    
    echo "Processing commit $i/$num_commits ($commit) with date $commit_date"
    
    export GIT_AUTHOR_DATE="$commit_date"
    export GIT_COMMITTER_DATE="$commit_date"
    
    git checkout "$commit" -- .
    
    # Bulk replacements
    grep -rl "priyanshu Harshbodhi" . 2>/dev/null | xargs sed -i "s/priyanshu Harshbodhi/$NEW_NAME/g" 2>/dev/null
    grep -rl "priyanshu Harshbodhi" . 2>/dev/null | xargs sed -i "s/priyanshu Harshbodhi/$NEW_NAME/g" 2>/dev/null
    grep -rl "3D Solar System Simulator" . 2>/dev/null | xargs sed -i "s/3D Solar System Simulator/3D Solar System Simulator/g" 2>/dev/null
    grep -rl "3D Solar System Simulator" . 2>/dev/null | xargs sed -i "s/3D Solar System Simulator/3D Solar System Simulator/g" 2>/dev/null
    
    if [ -f "LICENSE" ]; then sed -i "s/priyanshu Harshbodhi/$NEW_NAME/g" LICENSE; fi
    if [ -f "package.json" ]; then 
        sed -i "s/threejs-journey-exercise/3d-solar-system-simulator/g" package.json
        if ! grep -q "author" package.json; then
            sed -i 's/"name":/"author": "'"$NEW_NAME"' <'"$NEW_EMAIL"'>",\n  "name":/' package.json
        fi
    fi
    if [ -f "src/index.html" ]; then sed -i "s/Solar System/3D Solar System Simulator/g" src/index.html; fi
    if [ -f "readme.md" ]; then sed -i "s/Solar System/3D Solar System Simulator/g" readme.md; fi

    msg=$(git log -1 --pretty=%B "$commit")
    msg=$(echo "$msg" | sed "s/priyanshu Harshbodhi/$NEW_NAME/g" | sed "s/3D Solar System Simulator/3D Solar System Simulator/g")
    
    git add .
    git commit -m "$msg" --no-verify --quiet
done

git branch -f main super-clean-rewrite
git checkout main
git branch -D super-clean-rewrite

echo "Super clean rewrite complete."
git log -n 5 --pretty=format:"%h %an <%ae> %ad %s" --date=short
