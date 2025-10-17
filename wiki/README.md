# Wiki Documentation for Container Apps Store API Microservice

This directory contains comprehensive wiki documentation for the Container Apps Store API Microservice project.

## 📖 About This Wiki

This wiki provides detailed documentation for deploying, configuring, developing, and troubleshooting the microservice-based sample application on Azure Container Apps.

## 📚 Documentation Files

### Getting Started
- **[Home.md](Home.md)** - Wiki home page with overview and navigation
- **[Getting-Started.md](Getting-Started.md)** - Quick start guide for all deployment options

### Architecture & Development
- **[Architecture-Overview.md](Architecture-Overview.md)** - System architecture and design patterns
- **[Local-Development.md](Local-Development.md)** - Complete local development guide

### Deployment & Operations
- **[Deployment-Guide.md](Deployment-Guide.md)** - Step-by-step Azure deployment instructions
- **[API-Documentation.md](API-Documentation.md)** - Complete API reference for all services
- **[Troubleshooting.md](Troubleshooting.md)** - Common issues and solutions

## 🚀 How to Use This Wiki

### Option 1: GitHub Wiki (Recommended)

To publish this documentation to the GitHub Wiki:

1. **Clone the Wiki Repository:**
   ```bash
   git clone https://github.com/TeplrGuy/container-apps-store-api-microservice.wiki.git
   ```

2. **Copy Wiki Files:**
   ```bash
   cp wiki/*.md container-apps-store-api-microservice.wiki/
   cd container-apps-store-api-microservice.wiki
   ```

3. **Commit and Push:**
   ```bash
   git add .
   git commit -m "Add comprehensive wiki documentation"
   git push origin master
   ```

4. **View on GitHub:**
   - Navigate to: https://github.com/TeplrGuy/container-apps-store-api-microservice/wiki

### Option 2: Read Locally

Simply open the markdown files in any markdown viewer or IDE:

```bash
# Using VS Code
code wiki/Home.md

# Using a markdown viewer
mdv wiki/Home.md
```

### Option 3: Generate Static Site

Use a static site generator like MkDocs or Jekyll:

**Using MkDocs:**
```bash
pip install mkdocs
mkdocs serve
# Visit http://localhost:8000
```

## 📋 Documentation Structure

```
wiki/
├── README.md                      # This file
├── Home.md                        # Wiki home page
├── Getting-Started.md             # Quick start guide
├── Architecture-Overview.md       # System architecture
├── Deployment-Guide.md            # Azure deployment
├── API-Documentation.md           # API reference
├── Local-Development.md           # Development guide
└── Troubleshooting.md            # Problem solving
```

## 🔄 Keeping Documentation Updated

When making changes to the codebase:

1. Update relevant wiki pages
2. Keep code examples current
3. Update screenshots if UI changes
4. Review and update troubleshooting guide

## ✨ Contributing to Documentation

To improve this documentation:

1. **Fix errors or typos:**
   - Edit the markdown files
   - Submit a pull request

2. **Add new content:**
   - Create new .md files in the wiki directory
   - Update Home.md to link to new pages
   - Submit a pull request

3. **Update existing content:**
   - Edit the relevant markdown file
   - Ensure all links still work
   - Submit a pull request

## 📝 Markdown Guidelines

When editing wiki pages:

- Use ATX-style headers (`#`, `##`, `###`)
- Include code examples with proper syntax highlighting
- Add tables for structured data
- Use relative links between wiki pages: `[Link Text](Page-Name)`
- Include examples and screenshots where helpful

## 🔗 Quick Links

- **Repository:** https://github.com/TeplrGuy/container-apps-store-api-microservice
- **Wiki:** https://github.com/TeplrGuy/container-apps-store-api-microservice/wiki
- **Issues:** https://github.com/TeplrGuy/container-apps-store-api-microservice/issues
- **Pull Requests:** https://github.com/TeplrGuy/container-apps-store-api-microservice/pulls

## 📧 Support

For questions or issues with the documentation:

1. Check the [Troubleshooting Guide](Troubleshooting.md)
2. Search [existing issues](https://github.com/TeplrGuy/container-apps-store-api-microservice/issues)
3. Create a new issue if needed

## 📄 License

This documentation is part of the Container Apps Store API Microservice project and is licensed under the same license as the main project.

---

**Last Updated:** October 2025
**Maintained by:** TeplrGuy and contributors
