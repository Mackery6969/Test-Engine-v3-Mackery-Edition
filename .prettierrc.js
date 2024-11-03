/**
 * Configuration for formatting multiple file types.
 */
module.exports = {
  printWidth: 80,
  tabWidth: 2,
  useTabs: false,
  singleQuote: false,
  quoteProps: "preserve",
  bracketSpacing: true,
  trailingComma: "none",
  semi: false,
  plugins: ["prettier-plugin-xml"], // Explicitly add the XML plugin

  overrides: [
    {
      files: "*.json",
      options: {
        parser: "json"
      }
    },
    {
      files: "*.md",
      options: {
        parser: "markdown",
        proseWrap: "always"
      }
    },
    {
      files: "*.txt",
      options: {
        printWidth: 80,
        proseWrap: "preserve"
      }
    },
    {
      files: "*.hxml",
      options: {
        parser: "babel",
        singleQuote: true
      }
    },
    {
      files: "*.xml",
      options: {
        parser: "xml",
        bracketSpacing: true,
        singleQuote: true
      }
    }
  ]
}
