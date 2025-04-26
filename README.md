# infinity-oil-delivery

## Description
infinity-oil-delivery is a RedM/FiveM resource that adds an immersive oil delivery and selling system to your server. Players can interact with oil NPCs, collect oil barrels, deliver them to various locations, and sell oil for in-game currency. The system includes progress bars, prompts, and a simple NUI for selling items.

## Features
- Oil NPCs that spawn at configured locations
- Interactive prompts and dialogs for starting/canceling missions and selling oil
- Oil collection points with progress bar and animations
- Delivery missions with blips and rewards
- NUI-based item selling interface
- Configurable distances for NPC interaction and spawn
- Optimized for low CPU usage

## Requirements
- RedM or FiveM server
- [infinity_core](https://github.com/Infinity-Core/infinity_core) (for player/session management, notifications, and inventory)
- [infinity_needs](https://github.com/Infinity-Core/infinity_needs) (for inventory management)

## Installation
1. Download or clone this repository into your server's resources folder.
2. Ensure all dependencies are installed and started before this resource.
3. Add `ensure infinity-oil-delivery` to your `server.cfg`.
4. Configure `config.lua` to adjust NPC locations, distances, and other settings as needed.

## Usage
- Approach an oil NPC to start a delivery mission or sell oil.
- Collect oil at marked locations and deliver to the destination for rewards.
- Use the NUI interface to sell oil items for cash.

## Configuration
- Edit `config.lua` to set NPC locations, oil collection points, delivery routes.

## Credits
Developed by BZK Scripts. Special thanks to the Infinity Core team.

# Version
- Mining Oil
- Sell Oil
- Random Deliverys Oil

# Dependancies
- infinity-core
- infinity-needs

# Starting the resource
- add the following to your server.cfg file : ensure infinity-oil-delivery

# Installation
- ensure that the dependancies are added and started
- add infinity-oil-delivery to your resources folder
- add images to your "\infinity-needs\inventory\items"

# Item Setup
To use the oil system, you must create the 'oil' item in your inventory system:

- **Add the following to your inventory items file (`infinity-needs/inventory/items.json`):**

```
    {
        "name"              : "oil",
        "label"             : "Oil",
        "description"       : "Oil not refined",
        "weight"            : 0.10,
        "type_item"         : "standard",
        "for_item"          : "",
        "bonus"             : 0,
        "bonus2"            : 0,
        "bonus3"            : 0, 
        "droped"            : 1,
        "rare"              : "common",
        "img"               : "items/water.png"
    },
```

- **Add the image:**
  - Place the image (e.g., `oil.png` or your custom image) in `infinity-needs/inventory/items/`.
  - This image will be shown in the NUI modal when selling oil.

# Discord
- Infinity Core: [https://discord.gg/vut2YAEG2C](https://discord.gg/vut2YAEG2C)
- BZK Scripts: [https://discord.gg/zHpuu3ENTR](https://discord.gg/zHpuu3ENTR)
