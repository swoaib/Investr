---
trigger: always_on
---

Dont hardcode strings, they should be translateable

When changing a string or adding one, always make sure to change or add the corresponding in all supported languages

When adding a service or repository etc.. make sure to use dependency injection and not creating a new instance of it