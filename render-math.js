// render-math.js
const fs = require("fs");
const path = require("path");
const katex = require("katex");

const inputDir = process.argv[2];
const outputDir = process.argv[3];

if (!inputDir || !outputDir) {
  console.error("Usage: node render-math.js <inputDir> <outputDir>");
  process.exit(1);
}

fs.mkdirSync(outputDir, { recursive: true });

function processFile(filePath, relativePath = "") {
  const fullInputPath = path.join(filePath);
  const stat = fs.statSync(fullInputPath);

  if (stat.isDirectory()) {
    const children = fs.readdirSync(fullInputPath);
    children.forEach((child) =>
      processFile(path.join(filePath, child), path.join(relativePath, child))
    );
  } else if (filePath.endsWith(".html")) {
    console.log("Processing file: ", relativePath);

    let content = fs.readFileSync(fullInputPath, "utf8");

    // 1. Render block math first: $$...$$
    content = content.replace(/\$\$\s*([\s\S]+?)\s*\$\$/g, (_, math) => {
      return katex.renderToString(math, {
        throwOnError: false,
        displayMode: true,
      });
    });

    // 2. Render inline math: $...$ (but not inside block math)
    content = content.replace(
      /(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)/g,
      (_, math) => {
        return katex.renderToString(math, {
          throwOnError: false,
          displayMode: false,
        });
      },
    );

    const outputFilePath = path.join(outputDir, relativePath);
    const outputFileDir = path.dirname(outputFilePath);
    fs.mkdirSync(outputFileDir, { recursive: true });
    fs.writeFileSync(outputFilePath, content);
  }
}

processFile(inputDir);
