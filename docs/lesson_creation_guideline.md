# Lesson Creation Guideline

## 1. Content Structure
-   **Length**: 3 to 9 pages per lesson.
-   **Tone**: Educational, Encouraging, "Graham-style" (Focus on safety/value), but modern.
-   **Flow**:
    -   **Introduction**: Hook the user, define the concept.
    -   **Body**: Explain the "Why" and "How". Break complex topics into single-concept pages.
    -   **Conclusion**: actionable summary or rule of thumb.

## 2. Visual Style (SVGs)
-   **Format**: SVG (Scalable Vector Graphics).
-   **Dimensions**: `300x300` or `400x300` viewport.
-   **Style**: Flat, Geometric, Minimalist.
-   **Theme Compatibility**: MUST work on both Light and Dark backgrounds.
    -   Use `fill="none"` or transparent backgrounds.
    -   Use hardcoded standard colors from the app palette for strokes/fills:
        -   Green: `#4CAF50` (Success/Growth)
        -   Red: `#F44336` (Risk/Loss)
        -   Blue: `#2196F3` (Info/Neutral)
        -   Orange: `#FF9800` (Warning/Time)
        -   White/Light Grey: `#FFFFFF` or `#EEEEEE` (Elements that must pop on dark mode; check visibility on light mode). *Tip: Use off-white or light gray stroking if uncertain, or rely on the app's theme colors if possible (though harder in raw SVG).*
        -   **Best Practice**: Use `stroke` with standard widths (e.g., `stroke-width="2"`). Avoid large filled areas of white/black that might look odd in reverse themes.

## 3. Localization
-   **Files**:
    -   `lib/l10n/app_en.arb` (Master)
    -   `lib/l10n/app_no.arb` (Norwegian)
    -   `lib/l10n/app_ja.arb` (Japanese)
-   **Keys**: Use camelCase keys prefixed with the lesson topic (e.g., `bondsDefinition`, `bondsRisk`).

## 4. Implementation Checklist
1.  **Draft Content**: Outline the 3-9 pages text.
2.  **Create Assets**: Generate/Code the SVGs. Place in `assets/images/education/`.
3.  **Localize**: Add strings to all 3 ARB files.
4.  **Code**: Add `Lesson` object to `LearnScreen.dart`.
5.  **Verify**: Check page count (3-9) and asset visibility.
