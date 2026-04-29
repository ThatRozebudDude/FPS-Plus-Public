package editors.ui;

import flixel.FlxG;
import editors.ui.UIManager;
import editors.ui.Box;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxSignal;
import flixel.FlxSprite;

using StringTools;

typedef PanelTab = {
	var name:String;
	var tab:Box;
	var title:UIText;
	var group:FlxTypedSpriteGroup<FlxSprite>;
	var manager:UIManager;
}

class Panel extends UIElement
{

	var panelBackground:Box;
	public var tabs:Array<PanelTab> = [];
	public var selectedTab:Int = 0;

	public var onOverlap:FlxSignal = new FlxSignal();
	public var onOverlapStop:FlxSignal = new FlxSignal();

	public function new(_x:Float, _y:Float, _width:Float, _height:Float, _tabs:Array<String>, _tabHeight:Float){
		super(_x, _y);
		if(_tabs.length < 1){ _tabs = [""]; }

		panelBackground = new Box(0, _tabHeight - Box.BORDER_SIZE, _width, _height - (_tabHeight - Box.BORDER_SIZE));
		panelBackground.onOverlap.add(function(){ onOverlap.dispatch(); });
		panelBackground.onOverlapStop.add(function(){ onOverlapStop.dispatch(); });

		for(i in 0..._tabs.length){
			var panelTab:PanelTab = {name: _tabs[i], tab: null, title: null, group: null, manager: new UIManager()};

			panelTab.tab = new Box(((_width/4)*i) - (Box.BORDER_SIZE * i/(_tabs.length-1)), 0, (_width/4)+Box.BORDER_SIZE, _tabHeight);
			panelTab.tab.onClick.add(function(){ changeTab(i); });

			panelTab.group = new FlxTypedSpriteGroup<FlxSprite>(Box.BORDER_SIZE, _tabHeight);
			panelTab.group.visible = false;
			
			panelTab.title = new UIText(panelTab.tab.getMidpoint().x, panelTab.tab.getMidpoint().y, panelTab.name, 0.6);
			panelTab.title.y -= panelTab.title.height/2;
			panelTab.title.x -= panelTab.title.width/2;

			panelTab.manager.onFocusSwitch.add(function(element:UIElement){
				if(element == null){ return; }
				panelTab.group.remove(element, true);
				panelTab.group.add(element);
			});

			tabs.push(panelTab);
		}

		add(panelBackground);
		for(tab in tabs){
			add(tab.tab);
			add(tab.title);
			add(tab.group);
		}

		changeTab(0);

		elementWidth = panelBackground.width;
		elementHeight = panelBackground.y - y + panelBackground.width;
	}

	override public function update(elapsed:Float):Void{
		disableNonActiveTabs();
		super.update(elapsed);
	}

	override function destroy() {
		super.destroy();
	}

	function disableNonActiveTabs():Void{
		for(i in 0...tabs.length){
			if(i != selectedTab){
				tabs[i].manager.allowInteraction = false;
			}
		}
	}

	public function addToTab(tabName:String, obj:FlxSprite):Void{
		for(tab in tabs){
			if(tab.name == tabName){
				tab.group.add(obj);
				if(obj is UIElement){
					cast(obj, UIElement).manager = tab.manager;
				}
				return;
			}
		}
		trace('No tab with the name "$tabName" exists.');
	}

	public function changeTab(tabIndex:Int):Void{
		selectedTab = tabIndex;
		for(i in 0...tabs.length){
			if(tabIndex == i){
				tabs[i].tab.fillColor = UIColors.SELECTED_COLOR;
				tabs[i].title.color = UIColors.SELECTED_TEXT_COLOR;
				tabs[i].group.visible = true;
			}
			else{
				tabs[i].tab.fillColor = UIColors.FILL_COLOR;
				tabs[i].title.color = UIColors.FILL_TEXT_COLOR;
				tabs[i].group.visible = false;
			}
		}
	}

	public function isAnythingFocused():Bool{
		for(tab in tabs){
			if(tab.manager.focused != null){
				return true;
			}
		}
		return false;
	}
	
}