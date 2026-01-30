---
trigger: always_on
---

Dont hardcode strings, they should be translateable

When changing a string or adding one, always make sure to change or add the corresponding in all supported languages

When adding a service or repository etc.. make sure to use dependency injection and not creating a new instance of it

Always make sure to fix all issues, you can check them by running flutter analyze

Dont hardcode buttom padding to make it fit on the phone, use safearea instead