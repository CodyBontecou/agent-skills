# PDF

Read, merge, split, rotate, watermark, create, fill forms, encrypt/decrypt, extract images, and OCR scanned PDFs. Covers everything you might need to do with PDF files.

## Tools

### Python Libraries

| Library | Use Case |
|---------|----------|
| `pypdf` | Merge, split, rotate, encrypt, extract metadata |
| `pdfplumber` | Extract text and tables with layout preservation |
| `reportlab` | Create new PDFs from scratch |
| `pytesseract` + `pdf2image` | OCR scanned PDFs |

### Command-Line Tools

| Tool | Use Case |
|------|----------|
| `pdftotext` | Extract text (with layout) |
| `qpdf` | Merge, split, rotate, decrypt |
| `pdftk` | Merge, split, rotate |
| `pdfimages` | Extract images |

## Quick Examples

```python
# Extract text
from pypdf import PdfReader
reader = PdfReader("document.pdf")
text = "".join(page.extract_text() for page in reader.pages)

# Merge PDFs
from pypdf import PdfWriter
writer = PdfWriter()
for pdf in ["doc1.pdf", "doc2.pdf"]:
    for page in PdfReader(pdf).pages:
        writer.add_page(page)
writer.write(open("merged.pdf", "wb"))

# Extract tables
import pdfplumber
with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        tables = page.extract_tables()
```

See [SKILL.md](./SKILL.md) for complete examples covering all operations, including form filling and PDF creation with reportlab.
