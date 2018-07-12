//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

// Shared left side buttons, included by everywhere vote sub-menu
#undef	CHOICE_SIZE_X
#define CHOICE_SIZE_X		220

#undef CHOICE_X_START
#define CHOICE_X_START		-324

#undef CHOICE_HORIZONTAL_ALIGN
#define CHOICE_HORIZONTAL_ALIGN HORIZONTAL_ALIGN_CENTER

#undef CHOICE_VERTICAL_ALIGN
#define CHOICE_VERTICAL_ALIGN VERTICAL_ALIGN_TOP

//CHOICE_BUTTON( 2, "@MPUI_RESTART_MAP", exec "cmd callvote map_restart"; close self; )
CHOICE_BUTTON_VIS( 2, "@MPUI_RESTART_MAP", exec "cmd callvote map_restart"; close self; setdvar ui_allowvote_restartmap 0;, when ( dvarint( ui_allowvote_restartmap ) == 1 ); )
CHOICE_DBUTTON_VIS( 2, "@MPUI_RESTART_MAP", when ( dvarint( ui_allowvote_restartmap ) != 1 ); )

//CHOICE_BUTTON( 3, "@MPUI_NEXT_MAP", exec "cmd callvote map_rotate"; close self; )
CHOICE_BUTTON_VIS( 3, "@MPUI_NEXT_MAP", exec "cmd callvote map_rotate"; close self;, when ( dvarint( ui_allowvote_nextmap ) == 1 ); )
CHOICE_DBUTTON_VIS( 3, "@MPUI_NEXT_MAP", when ( dvarint( ui_allowvote_nextmap ) != 1 ); )

//CHOICE_BUTTON( 4, "@MPUI_CHANGE_MAP", open changemap; close changegametype; close kickplayer; close callvote; )
CHOICE_BUTTON_VIS( 4, "@MPUI_CHANGE_MAP", open changemap; close changegametype; close kickplayer; close callvote;, when ( dvarint( ui_allowvote_changemap ) == 1 ); )
CHOICE_DBUTTON_VIS( 4, "@MPUI_CHANGE_MAP", when ( dvarint( ui_allowvote_changemap ) != 1 ); )

//CHOICE_BUTTON( 5, "@MPUI_CHANGE_GAME_TYPEMAP", open changegametype; close changemap; close kickplayer; close callvote; )
CHOICE_BUTTON_VIS( 5, "@MPUI_CHANGE_GAME_TYPEMAP", open changegametype; close changemap; close kickplayer; close callvote;, when ( dvarint( ui_allowvote_changegametype ) == 1 ); )
CHOICE_DBUTTON_VIS( 5, "@MPUI_CHANGE_GAME_TYPEMAP", when ( dvarint( ui_allowvote_changegametype ) != 1 ); )

//CHOICE_BUTTON( 6, "@MPUI_KICK_PLAYER", open kickplayer; close changemap; close changegametype; close callvote; )
CHOICE_BUTTON_VIS( 6, "@MPUI_KICK_PLAYER", open kickplayer; close changemap; close changegametype; close callvote;, when ( dvarint( ui_allowvote_kickplayer ) == 1 ); )
CHOICE_DBUTTON_VIS( 6, "@MPUI_KICK_PLAYER", when ( dvarint( ui_allowvote_kickplayer ) != 1 ); )


// restoring position/size
#undef	CHOICE_SIZE_X
#define CHOICE_SIZE_X		200

#undef  SECTION_X_OFFSET
#define SECTION_X_OFFSET 	60
