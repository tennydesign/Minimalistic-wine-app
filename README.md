# prj3-Wine-Store-App
This third App is a minimalistic wine store with some clever hacking in it. 

<img width="1535" alt="w1" src="https://user-images.githubusercontent.com/17029800/33865389-6402c4e8-dea6-11e7-8cc0-cd44a0cf0605.png">

This project features: 

- GCD async queues.
- Core Data. 
- CoreMotion (card shadow moves with gyroscope).
- Some very cool collectionView stretching (including the tinder-like, swipe right and left, add/remove to cart feature) 
- Very into MVC (for the good and the bad with the huge controllers).
- An extremely responsive main cell, with clever auto-layout hack, plays adaptively the entire catalog. 
- Only two cocoapods (slider up menu and star ratings... by now I hate messy cocoapods) 
- Some serious real-time database with Firebase. 
- A more dense OOP structure. 
- Fully integrated with Apple Pay and PassKit. 
- Notifications (APN).
- JSON serialization using Decodable objects/ parsing.
- Two storyboards. (one customer facing, one store owner facing). 
- Full e-commerce flow (From inserting products in catalog to Apple Pay checkout)
- Smart catalog for entering new products checks against wine data api's and fill the info for the store owner avoiding ghost data. 
- A very minimalistic customer facing storyboard (one main collectionViewController), with one scene. 
- Authentication (google sign in, and email sign in)
- Access to five different APIs. (involved in the wine label image recognition workflow)
- Protocols, Singletons (oh, I love singletons) and Delegates (many involved in controling the animations).
- Very intricate animations. 
- Custom designed navigation controls, from scratch, not cocoapods. (top bar is actually an enhanced collection view with programatic auto-layout and positioning). 
- Apple's Material Design and Human Interface Guidelines. 
- Balsamiq prototype.
- POP (Marvel) prototype. 

** This App ranked #1 out of 15 in the class (General Assembly iOS immersive SF). 
 
 Total hacking time: ~360 hours.

Note: This project was huge, involving customer facing and backend interfaces with what looked like an infinite requirements list. It was built by me and [Jun Lee](Https://www.Github.com/juntomlee) and it took a crazy sleep deprivation hacking schedule for us to finish this baby monster in two and a half weeks. In the end it looks simple and clean, but it's a beast =). 

Wireframe for the customer-facing interfaces. 
<img width="839" alt="screen shot 2017-12-11 at 19 10 57" src="https://user-images.githubusercontent.com/17029800/33865712-bf20c4b4-dea7-11e7-83bf-d93aad79cba2.png">

<img width="423" alt="screen shot 2017-12-11 at 20 20 30" src="https://user-images.githubusercontent.com/17029800/33867441-864340cc-deb1-11e7-8161-3b82591c670c.png">

[![Demo1](https://user-images.githubusercontent.com/17029800/33869650-cd483e0c-debe-11e7-9eb3-442bb7aed59a.png)](https://vimeo.com/246914048 "Demo - Click to watch")

[![Demo](https://user-images.githubusercontent.com/17029800/33866495-da791aa0-deab-11e7-8b6d-678c9f01c5ed.png)](https://vimeo.com/246907047 "Demo - Click to watch")

<img width="906" alt="screen shot 2017-12-11 at 18 53 09" src="https://user-images.githubusercontent.com/17029800/33865501-e1ed7d4e-dea6-11e7-837b-0dd334be95f9.png">

<img width="336" alt="screen shot 2017-12-11 at 18 53 54" src="https://user-images.githubusercontent.com/17029800/33865443-9c308378-dea6-11e7-9ad0-b08455443c59.png">

<img width="326" alt="screen shot 2017-12-11 at 18 54 16" src="https://user-images.githubusercontent.com/17029800/33865445-9c60ec0c-dea6-11e7-9a50-a6329775ab26.png">

<img width="591" alt="screen shot 2017-12-11 at 18 53 29" src="https://user-images.githubusercontent.com/17029800/33865447-9c7730e8-dea6-11e7-8dc1-b6f5cd451b77.png">


