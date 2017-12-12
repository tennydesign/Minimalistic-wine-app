# prj3-Wine-Store-App
This third App is a minimalistic wine store with some clever hacking in it. 

<img width="1421" alt="1" src="https://user-images.githubusercontent.com/17029800/33865357-43ef3f6a-dea6-11e7-9e88-06313d3c41a1.png">

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
