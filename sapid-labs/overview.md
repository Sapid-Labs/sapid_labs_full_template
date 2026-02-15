Sapid Labs is my personal software development lab. I am primarily a Flutter developer and I work on apps, websites, and backend services.

To maximize productivity, I have created a system for sharing updates across projects. All of my Flutter apps, including this sapid_labs_flutter_template, live in a `work` folder. 

The template is what all Sapid Labs apps are made from and it is essential that any improvements I make to the base app functionality make their way back to the template. 

Likewise, it is crucial that any updates made to the template are communicated to the child apps in some way.

Changes only need to be communicated in text (ex. a description of the change and why it was made. For instance, added a shared PhoneNumberValidator so that users cannot use invalid phone numbers at sign in). Then, when I open an app to work on it, I can refer these changes and have my AI agent implement them quickly before I start on anything new.

Changes are communicated to and from the template in a `sapid-todos.md` file. Each change includes the description of the change and an optional reason that will help the AI agent understand what needs to be done. The change can also refer to specific files.

When a change is implemented, the `sapid-todos.md` file for the implementing app should be updated so the change is deleted.

## Usage

- **`/add-todo`** — Propagate a change to sibling projects. Prompts for description, reason, and files, then appends to `sapid-todos.md` in all other Flutter projects under `~/projects/work/`.
- **`/sync-todos`** — Implement pending changes. Reads the current project's `sapid-todos.md`, lets you pick which to implement, then removes completed entries.