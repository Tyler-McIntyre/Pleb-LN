# Firebolt


## Prerequisites for instructions below
#### 1. Install Git
https://git-scm.com/downloads

#### 2. Install Flutter && Android Studio
https://docs.flutter.dev/get-started/install
##### Make sure you've also created a virtual device (an emulator) to use in android studio

#### 3. Install Visual Studio Code
https://code.visualstudio.com/

### 4. Install Node.js
https://nodejs.org/en/download/


## Getting Started

### Set your username in git
open the terminal and set your username with...
```
git config --global user.name "YourGitHubUsername"
```
You can then check that it was successful by entering
```
git config --global user.name
```

### Clone the repository
open a terminal and navigate to where you'd like to keep the repo. Use 'cd' to change the directory you're in,
for instance if my terminal is currently pointed at...
```
C:\Users\tmcin
```
and I want to store the repo in...
```
C:\Users\tmcin\repos
```
Then I will enter 'change directory' followed by the folder name
```
cd repos
```
I should then be in my repos folder where I will run the line below...
```
git clone https://github.com/Tyler-McIntyre/FireBolt
```
Git will check if you have permission to clone this repo by having you login to GitHub and confim your identity.
#### HEADS UP. Sometimes the window prompting you for your credentials will be hidden behind your other open windows on the screen!!!

### Open Visual Studio Code
File >> Open Folder >> Navigate to the cloned repo and select the folder

### Build the project dependencies 
In the toolbar click... Terminal >> New Terminal and enter...
```
flutter pub get
```
This will fetch the dependencies listed in the pubspec.yaml

### Run the emulator
Press
```
SHIFT + CTRL + P
```
This opens the command palette 
Enter & select 'Flutter: Launch Emulator' in the search bar.
Then choose the emulator you created earlier in Android studio

### Run the application
Use 
```
CTRL + F5 
```
to run the project without the debugger or open 'Run' in the top toolbar and select 'Run without the debugger'





## The backlog
A running list of tasks that need to be completed for this application. Anyone is welcome to edit it. If you see a task you'd like to work on, just add your name and it's yours! If there's any questions (which there will be a lot of) just ping me on discord in the #firebolt channel.
https://docs.google.com/spreadsheets/d/1LSVl5OSKyrjWt00WewR-J-PChMhZRTFUALc_x9mfIak/edit?usp=sharing

#### Design related items
Since we do not have a designated designer, and we are the users of this app. It would most likely be a good idea to bring UI related design tasks to the team to have a conversation about the direction we'd like to take with whatever the given task might be.

## Testing with polar
Download Polar for testing locally
https://lightningpolar.com/

As of now, Firebolt only support LND nodes, so when creating your local network make sure you're using LND nodes only.

You'll need three parameters to make the connection
select a node, select 'connect'
#### If you're using an an android emulator, 
The host will be 10.0.2.2. Android emulators use this as an alias for the local host (127.0.0.1)

#### find the port number
Under the connect tab, look at the rest host. You'll see the port number listed after the host. I.E. 127.0.0.1:8082. 8082 is your port.

#### find the macaroon
Under base64 you'll find the admin macaroon. This delegates read and write permissions to the user. Invoice and read-only are more restrictive.
