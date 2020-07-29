# Communities Social Navigation Menu

Navigation menus are great for declaratively managing a set of a list of navigation menu items that you can access programmatically within a custom component. A very common use case for a custom navigation component is the display of social links on a community. It is a design pattern seen throughout the web and a great way for a company to promote their social presence. There are quite a few ways that we could achieve this with code, but using a navigation menu will give an admin the ability to manage the menu items using a familiar tool.

<img src="screenshots/social-navigation-component.png" alt="Social Navigation"/>

## Features

The component consists of the following:

- Communities
- Navigation Setup
- Connect API
- Summer '20 Community Modules

## Installing Communities Social Navigation Menu using a Scratch Org

1. If you haven't already done so, authorize your hub org and provide it with an alias (**myhuborg** in the command below):

   ```
   sfdx force:auth:web:login -d -a myhuborg
   ```

1. Clone the repository:

   ```
   git clone https://github.com/schandlergarcia/lwc-scheduler-service
   cd lwc-scheduler-service
   ```

1. Create a scratch org and provide it with an alias (**ebikes** in the command below):

   ```
   sfdx force:org:create -s -f config/project-scratch-def.json -a lwc-scheduler
   ```

1. Push the app to your scratch org:

   ```
   sfdx force:source:push
   ```

1. Open the scratch org:

   ```
   sfdx force:org:open
   ```
