# How to Publish Wiki to GitHub

This guide explains how to publish the wiki documentation to GitHub Wiki.

## Quick Start

The easiest way to publish the wiki is to use the provided script:

```bash
# Make sure you're in the repository root
cd /path/to/container-apps-store-api-microservice

# Run the publish script
./wiki/publish-wiki.sh
```

The script will:
1. Clone the GitHub wiki repository
2. Copy all markdown files from the `wiki/` directory
3. Commit and push changes to GitHub

## Manual Publishing

If you prefer to publish manually:

### Step 1: Initialize the Wiki on GitHub

1. Go to https://github.com/TeplrGuy/container-apps-store-api-microservice/wiki
2. If the wiki doesn't exist yet, click **Create the first page**
3. Add any content and click **Save Page** to initialize the wiki

### Step 2: Clone the Wiki Repository

```bash
# Clone the wiki repository (it's a separate git repo)
git clone https://github.com/TeplrGuy/container-apps-store-api-microservice.wiki.git
cd container-apps-store-api-microservice.wiki
```

### Step 3: Copy Wiki Files

```bash
# Copy all markdown files from the main repository
cp /path/to/container-apps-store-api-microservice/wiki/*.md .
```

### Step 4: Commit and Push

```bash
# Add all markdown files
git add *.md

# Commit the changes
git commit -m "Add comprehensive wiki documentation"

# Push to GitHub
git push origin master
```

### Step 5: Verify

Visit https://github.com/TeplrGuy/container-apps-store-api-microservice/wiki to see your published documentation.

## Wiki Structure on GitHub

After publishing, your wiki will have the following pages:

- **Home** - Main landing page with navigation
- **Getting Started** - Quick start guide
- **Architecture Overview** - System architecture details
- **Deployment Guide** - Azure deployment instructions
- **API Documentation** - Complete API reference
- **Local Development** - Development environment guide
- **Troubleshooting** - Problem-solving guide

## Updating the Wiki

When you make changes to the wiki files in the main repository:

1. Edit the markdown files in the `wiki/` directory
2. Commit changes to the main repository
3. Run `./wiki/publish-wiki.sh` to update the GitHub wiki

## Wiki File Naming Conventions

GitHub Wiki uses the following conventions:

- `Home.md` → Home page (automatically shown at wiki root)
- `Getting-Started.md` → Accessible as `/wiki/Getting-Started`
- Spaces in filenames become dashes: `API Documentation.md` → `/wiki/API-Documentation`

## Linking Between Wiki Pages

In the markdown files, use these link formats:

```markdown
[Link Text](Page-Name)
```

Examples:
```markdown
[Getting Started](Getting-Started)
[API Documentation](API-Documentation)
[Troubleshooting](Troubleshooting)
```

## Adding New Wiki Pages

To add a new page:

1. Create a new `.md` file in the `wiki/` directory
2. Add content using markdown
3. Update `Home.md` to link to the new page
4. Run the publish script to update GitHub wiki

## Troubleshooting Wiki Publishing

### "Wiki not initialized" Error

**Problem:** Script fails with "wiki not initialized"

**Solution:**
1. Visit https://github.com/TeplrGuy/container-apps-store-api-microservice/wiki/_new
2. Create any page with any content
3. Click Save
4. Run the publish script again

### "Permission denied" Error

**Problem:** Cannot push to wiki repository

**Solution:**
- Ensure you have write access to the repository
- Check that you're authenticated with GitHub (run `gh auth login`)

### Wiki Pages Not Showing

**Problem:** Pages don't appear after publishing

**Solution:**
- Make sure file names use dashes instead of spaces
- Check that files have `.md` extension
- Verify files were successfully pushed (check wiki repo on GitHub)

## Alternative: GitHub UI

You can also edit the wiki directly through GitHub's web interface:

1. Go to the wiki page
2. Click **Edit** or **New Page**
3. Paste markdown content
4. Click **Save Page**

However, using the script is recommended for bulk updates and version control.

## Keeping Wiki in Sync

The wiki files in the main repository (`/wiki` directory) are the source of truth. Always:

1. Edit files in the main repository
2. Commit to main repository
3. Run publish script to sync to GitHub wiki

This ensures the documentation is version-controlled and available both in the repository and as a GitHub wiki.

## Resources

- [GitHub Wiki Documentation](https://docs.github.com/en/communities/documenting-your-project-with-wikis)
- [Markdown Guide](https://www.markdownguide.org/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)

---

**Need Help?** Create an issue at https://github.com/TeplrGuy/container-apps-store-api-microservice/issues
