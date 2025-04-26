extends Node

## Emitted when player is spawned.
signal stage_event_player_spawned()
## Emitted when player dies.
signal stage_event_player_died()
## Emitted when player reaches current room border.
signal stage_event_player_at_border()
## Emitted when scrolling starts.
signal stage_event_scroll_start()
## Emitted when scrolling is finished.
signal stage_event_scroll_finished()
## Emitted when boss is defeated.
signal stage_event_boss_defeated()
