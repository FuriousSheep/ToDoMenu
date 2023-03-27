# ToDoMeNu, a soft app to manage your spoons

## What this project is

The idea behind this app on the experience of a loved one who uses a menu of 
tasks and choses from them when they have the energy to work through something. 
Having the freedom to chose what activities they do depending on their energy 
and not having the pressure of regular todo lists is the apparent benefit of 
this approach, and guides the goals of this application: to provide a simple and
easy way to concoct a menu of activities from pre-written lists, depending on an
amount of energy - dubbed spoons. 

This is both practice for me and a present to someone I love, and to whomever it
may benefit. May it help you manage your energy when it is low, and help you 
focus it when high.

## Goals

What this app aims to do:
* Provide you with a way to organize regular and occasional activities.
* Manage your energy while allowing you to achieve your aims.
* Be as soft and calming as possible.

What this app wants to avoid:
* Pressure you into doing tasks. You're not a robot! You need rest!
* Sell your data. You don't need internet access to use the app after downloading it, there is no data collection, you keep your privacy.
* Organize your life. No dates, no due time. This is for regular activities that you can postpone.

## Development

Launch project on localhost : `npm start`

Current tools need to be reevaluated before being described in the readme.

## Roadmap

1. **Establish a work environment**
    * Elm language server
    * Hot reload
    * Hot compiling
    * Nix packet management
    * Nix app building

The idea here is to make it easy to work with this project. The less effort is needed to work on this, the easier for me - and for eventual contributors - to join.

Estimated time: 5-10 hours.

2. **Make a prototype / Fail faster**
    * Make it a pwa (manifest.json? learn more)
    * Create tasks page
    * Save tasks on local storage

The idea here is to test as fast as possible on the end platform. This is aimed to be a webapp, it should be a webapp from the very beginning. Also, it should be able to save and retrieve data from the phone, and that too should be a priority

Estimated time: 2-6 hours.

3. **Make the MVC**
    * Task list creation
    * Current task selection
    * Checking off current tasks

This is the end of the MVP. There should be a review here to assess past goals, reassess current and future goals, and take a decision on the future of the app.

Estimated time: 6-10 hours.

* **Additional features/ stretch goals**
  * Polished design (animations, soft corners, pastels)
  * Randomized completion of current tasks list
  * History of done task lists
  * Rewards when tasks done (kind words, soft haikus, cute animations, chill music)
  * Export/import data from files (encrypted?)
  * Close range secure data sharing?