# firebolt


## Prerequisites for instructions below
#### 1. Installed Git
https://git-scm.com/downloads

#### 2. Installed Flutter && Android Studio
https://docs.flutter.dev/get-started/install
##### Make sure you've also created a virtual device (an emulator) to use in android studio

#### 3. Installed Visual Studio Code
https://code.visualstudio.com/

### 4. Install Node.js
https://nodejs.org/en/download/


## Getting Started

### Clone the repository
open a terminal and navigate to where you'd like to keep the repo. Use 'cd' to change the directory you're in
for instance if my terminal is currently pointed at...C:\Users\tmcin\repos
```
C:\Users\tmcin
```
and I want to store the repo in...
```
C:\Users\tmcin\repos
```
Then I will enter this in the terminal
```
cd repos
```
I should then be in my repos folder where I will run the line below...
```
git clone https://github.com/Tyler-McIntyre/FireBolt
```

### Open Visual Studio Code
File >> Open Folder >> Navigate to the cloned repo and select the folder

### Run 'NPM install'
In the toolbar click... Terminal >> New Terminal and enter...
```
NPM install
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
