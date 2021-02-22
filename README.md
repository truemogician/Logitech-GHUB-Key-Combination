# **Key Combination Framework for Logitech GHUB**
## **Introduction**
+ ### **What is it ?**
  It is a lua script that builds a framework for Logitech GHUB to manage more complated key combination events than G-Shift provided by GUB itself.
+ ### **What's it used for ?**
  Extend the functionality of Logi mouses. With this framework, users can easily assign keyboard or macro mappings to all kinds of mouse button combinations. The number of keys isn't the limit, as long as your fingers could reach them at the same time :grin:.
+ ### **How to use it ?**
  1. Download **key combination.lua** from release  
  2. Append a few lua code to register events and add special handlers
  3. Open GHUB and add a new profile to your target application
  4. In the new profile, disable the buttons that you'll register in the script in "Assign" tab
  5. Create a new script through GHUB
  6. Copy and paste the framework and your own code into the GHUB script editor and save it
  7. Enjoy your mouse
  + Note that if your combination involves primary key and thus you disable it in the new profile, make sure you have alternative way, like using touch board, to do a primary click. Otherwise it's very likely that you lost control of your computer, since most users are not familiar with pure keyboard control.
+ ### **How to test or debug my assignment ?**
  Obviously, the simplest way to test is to activate your script in a profile and operate your mouse. But in case some inappropriate assignment might lead to terrible consequence, it's recommended to test the framework using the [test framework](src/test/test%20framework.lua) if you are familiar with lua.  
To properly make use of the test framework, you may refer to [test.lua](src/test/test.lua), it's a simple example. It's recommended to write test operations in [commands.txt](src/test/commands.txt) just as shown in *test.lua*
## **Documentation**
+ ### **Principle**
  Usually, a well-designed framework should work as a blackbox, thus there's no need for the user to know the principle. But because of the limit of GHUB Lua API, the use of this framework should be normalized to avoid some potential bugs, and the standard
+ ### **Globals**
  1. #### ***Action***
      A collection of all actions provided by G-series Lua API. The introduction of each action is written as comments, and their function could be easily guessed by its name. Since in most cases users just need to use the wrapped register methods, there's no need to put detailed documentation on this table.
  2. #### ***Button***
      The collection of mouse buttons. In GHUB API, mouse buttons are identified by an integer, which is hard to remember. This collection gives each button a meaningful name, making it easier to register.
  3. #### ***Settings***  
      *Settings.ScreenResolution* defines the current resolution of your screen. Only affect Action.Cursor.  
	  *Settings.MouseModel* define the model of your mouse. It determines the collection of buttons, in other words, the *Button* variable. Currently only "G502Hero" is supported, because that's the only model I have. I'll provide an easy way for users to configure their own model in the future and add some more common models.
  4. #### ***Event***
      The base table used to register events. Users only need to use it in the following sentence  
	  ```lua
	  Event:SomeRegisterMethod(parameters...)
	  ```  
	  Notice that you must use **":"**, the **colon** instead of **"."**, the **period** to call registering methods.
  5. #### ***Mouse***
      A collection of mouse functions like primary click and secondary click. Same as *Button*, it's just help you to memory.
  6. #### ***CombinedEventHandler***
      The core table of the framework. But here for users, it's just used for adding special handlers. It's only for few special behavior beyond the basic framework, which won't be in need in most cases. 
	  ```lua
	  CombinedEventHandler:AddSpecialHandler(
		  handle: (this: table, event: string, button: string, pressed: string) => any
		  auxilary : any
	  )
	  ```
	  Refer to [test.lua](src/test/test.lua) for more implementation details.
+ ### **Register**
  For most cases, all the code you need to write yourself is registering. Here's some most commonly used methods.  
  1. #### ***RegisterBind***
  2. #### ***RegisterReleasedBind***
  3. #### ***RegisterReleasedMacro***