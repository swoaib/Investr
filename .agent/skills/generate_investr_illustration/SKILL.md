---
name: generate_investr_illustration
description: Generates illustrations for the Investr app following strict style guidelines (flat, minimalist, vector-style).
---

# Investr Illustration Generator

This skill helps you generate image prompts and images that adhere strictly to the Investr app's design language.

## The Formula

Every illustration prompt MUST follow this structure:

`[Style Definition]` + `[Subject]` + `[Visual Description]` + `[Color Palette/Constraint]`

### 1. Style Definition (MANDATORY)
Always start with:
> "A flat, modern, minimalist vector-style illustration on a white background representing..."

### 2. Subject
The specific concept being illustrated (e.g., 'Stock Ownership', 'Compound Interest').

### 3. Visual Description
A concrete, simple visual metaphor. Avoid text inside the image if possible (except for simple labels if absolutely necessary).
- **Good:** "A snowball rolling down a hill."
- **Bad:** "A complex detailed scene of a stock exchange floor."

### 4. Color Palette (MANDATORY)
> "Blue and green color palette, clean lines."
(Use Red only for negative concepts like 'Inflation' or 'Loss').

## Technical Constraints
- **Background:** Pure White (#FFFFFF).
- **Style:** Flat Vector Art, Minimalist.
- **Colors:** Investr Blue, Growth Green, Grey/Black accents. No gradients or 3D shading.

## Usage

When the user asks for an illustration, use the `generate_image` tool with a prompt constructed using the formula above.

### Example Prompts

**Stock Ownership**
"A flat, modern, minimalist vector-style illustration on a white background representing 'Stock Ownership'. Visualizes a modern office building or factory formed by puzzle pieces, with one distinct piece highlighted or floating. Blue and green color palette, clean lines."

**Compound Interest**
"A flat, modern, minimalist vector-style illustration on a white background representing 'Compound Interest'. Visualizes a snowball rolling down a hill, getting larger as it gathers more snow. Blue and green color palette, clean lines."
