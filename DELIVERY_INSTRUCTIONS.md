# Delivery Instructions

## Problem
The compiled JAR files are too large (~400MB) to push to GitHub.

## Solution
We don't commit compiled artifacts to Git. Instead:

1. **Source code** goes in Git (lightweight)
2. **Compiled distribution** is built locally and shared via GitHub Releases

## Workflow

### For Development (pushing to GitHub)

The `.gitignore` now excludes:
- All `*.jar` files
- All `target/` directories  
- The entire `DeliveryFolder/`

This keeps your repository small and clean.

### For Creating a Distribution Package

1. **Build the delivery package:**
   ```bash
   ./build-delivery.sh
   ```
   
   This will:
   - Compile all microservices
   - Create `DeliveryFolder/CodeKataBattleProject/` with:
     - All microservice JARs
     - Run scripts (Linux & Windows)
     - Database scripts
     - README with instructions
     - Logs directory

2. **Create ZIP for distribution:**
   ```bash
   cd DeliveryFolder
   zip -r CodeKataBattleProject.zip CodeKataBattleProject/
   ```

3. **Share via GitHub Releases:**
   - Go to your repository on GitHub
   - Click "Releases" → "Create a new release"
   - Upload `CodeKataBattleProject.zip` (up to 2GB allowed)
   - Users can download and run without building

### For Users Receiving the Package

1. Download the ZIP from GitHub Releases
2. Unzip it
3. Run the startup script:
   - **Linux/Mac:** `cd bin && ./runCKB.sh`
   - **Windows:** `cd bin && runCKB.bat`

## Removing Large Files from Git History

If you already committed large files, remove them:

```bash
# Find large files
git rev-list --objects --all | \
  git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
  sed -n 's/^blob //p' | \
  sort --numeric-sort --key=2 | \
  tail -n 10

# Remove them from history
git filter-repo --path DeliveryFolder/ --invert-paths
git filter-repo --path '*.jar' --invert-paths
git filter-repo --path 'target/' --invert-paths

# Force push
git push origin --force --all
```

## Benefits

✅ Small repository size  
✅ Fast clones and pulls  
✅ Clean separation of source and artifacts  
✅ Can distribute large packages via Releases  
✅ Industry best practice
