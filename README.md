SLACK BIBLE BOT
==================

Setting this up with [Slack](https://slack.com/) is simple.

In your "Integration Settings" add an **Outgoing WebHooks** entry with these parameters:

  - Channel : Up to your discretion.  It is highly recommended you limit to a specific channel.  If you are not quite sure just choose '#random'.
  - Trigger Word(s) : In this version the only words that will be recognized are 'bible','gospel,'scripture'.  Based on recommendations (Pull Requests) there may be more added later.
  - URL(s) : this **must be** 'https://disciplr.herokuapp.com/bible'.  This, again, is likely to change in future releases but I expect to maintain backward-compatibility.
  - Token : This should be unchanged and can be ignored
  - Descriptive Label : This is also up to your discretion but I recommend 'Bible Verse Expert'
  - Customize Name : 'god'
  - Customize Icon : I _really_ like the 'church' icon
  
Click "Save Settings" and you are ready to go.

![Integration Settings](integration_settings.png?raw=true)

![Chuch Emoji](church_emoji.png?raw=true)

In [Slack](https://slack.com/) you simply type something like `bible verse John 3:16` and will get a response like this

![John 3:16](bible_verse.png?raw=true)

Some supported alternatives are `bible gospel 1 Peter 2:2` and `bible scripture Matthew 5:9`

In addition, you can simply supply a _topic_ and get a random related verse: `bible money`
---

Acknowledgement and thanks to [GetBible.net](http://getbible.net/api) for their API that provides the scripture.  I have built this in a modular fashion, though, in order to allow *other* sources if desired.
