# Agreement

This document outlines the agreed coding and Git conventions for the Pao! project. All contributors are expected to follow these rules throughout development.

---

## CODE

1. **Give comments for each function or section of code** that you work on, to help others understand.
   > ex. `// Check if health is out`

2. **Variable name → function of the variable**, use camelCase.
   > ex. `var physicsBody`

3. **Commit and push for every change** that you do.

4. **For pull requests**, only do when you are finished with all your work in that feature.

5. **Follow separation of concern** — use the ECS-State Machine-Manager framework.

6. **Make the interface first together** as the *reference* (acuan) throughout making the app.

---

## GIT

1. **Use short, clear commit messages** to define your work to other developers.

2. **Follow commit conventions** from the GA (Fix, Refactor, etc.)
   > ex. `Fix: Collision does multiple demage`

3. **Pull main to your branch** before making a pull request to dev — make sure your branch is up to date.

4. **Branch name uses `feature/<your-feature-name>`** — ALWAYS PUSH TO YOUR BRANCH! NOT ANY OTHER.

5. **Step-by-step workflow:**
   - Pull dev
   - Do your job
   - Commit & push with a clear message
   - Pull dev again (just to make sure)
   - Make pull request to dev

6. **If there is a conflict**, make sure to resolve it in your own branch 

7. **If you want to rearrange folders**, confirm with the other tech members — **DO NOT CHANGE THE FOLDER STRUCTURE BY YOURSELF**.

