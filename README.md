# firebolt


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
NPM run build
```
This will install the dependencies for the app

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
