## 1.0.3
- Publish Date: Sep 5, 2023
- Content
  - fix Nothing new invocation issue

## 1.0.2
- Publish Date: Sep 5, 2023
- Content
  - fix either and maybe to_s implementation
  - add unboxing method to maybe and either

## 1.0.1
- Publish Date: Sep 3, 2023
- Content
  - fix import error due to change of project structure

## 1.0.0
- Publish Date: Sep 2, 2023
- Content
  - added simple helper functions and their curry version (module `Fun` and `CurryFun`)
  - kernel extension
    - Array: added `head`, `tail`, `init` and `xprod`
    - String: added `head`, `tail`, `init` and `last`
  - added typeclass
    - either
    - maybe
    - reader
    - state
    - writer
  - added test and rbs of the following parts
    - module `Fun`, `CurryFun`
    - kernel extension Array and String