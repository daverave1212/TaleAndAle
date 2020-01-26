

package scripts;

import com.stencyl.graphics.G;
import com.stencyl.graphics.BitmapWrapper;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;
import com.stencyl.models.Joystick;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;

import openfl.ui.Mouse;
import openfl.display.Graphics;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.joints.B2Joint;

import com.stencyl.utils.motion.*;

/*


*/

class ItemPopupUI{

	public var constants = {
		width	 	: 150,
		height	 	: 75,
		x 			: 165,
		y 			: 122.5,
		itemX		: -1.0,	// Set in constructor
		itemY		: -1.0,	// Set in constructor
		itemWidth	: 34,
		itemHeight	: 34,
		titleX		: -1.0,	// Set in constructor
		titleY		: -1.0,	// Set in constructor
		descriptionX: -1.0, // Set in constructor
		descriptionY: -1.0,  // Set in constructor
		descriptionWidth: -1.0,  // Set in constructor
		descriptionHeight: 100
	}
	
	private function initConstants(){
		constants.itemX = constants.x + 5;
		constants.itemY = constants.y + 5;
		constants.titleX = constants.itemX + constants.itemWidth + 5;
		constants.titleY = constants.itemY + 5;
		constants.descriptionX = constants.titleX;
		constants.descriptionY = constants.titleY + 20;
		constants.descriptionWidth = constants.width - constants.itemWidth - 10;
	}
	
	public var scopes = {
		Sell_Item	: 1,
		Buy_Item	: 2,
		Use_Item	: 3
	}
	
	public var isOpen	= false;
	public var iconFrameBitmap			: BitmapData;
	public var backgroundBitmap			: BitmapData;
	public var background	  			: ImageX;
	public var iconFrame	  			: ImageX;
	public var icon			  			: ImageX;
	public var closeButton				: Button;
	public var button					: Button;
	public var currentlyOpenItem		: Item;
	public var currentlyOpenInventory	: Inventory<Item>;	// Same as below
	public var currentScope				: Int;
	public var currentInventoryScope	: Int;
	public var descriptionTextBox		: TextBox;
	

	
	public function new(){
		initConstants();
		backgroundBitmap = getExternalImage("ui/PopupBackground.png");
		iconFrameBitmap	 = getExternalImage("ui/IconFrame.png");
		closeButton = new Button(ActorTypes.popupCloseButton(), "Inventory");
		button	 	= new Button(ActorTypes.popupButton(), "Inventory");
		descriptionTextBox = new TextBox(Std.int(constants.descriptionWidth), Std.int(constants.descriptionHeight), constants.descriptionX, constants.descriptionY, FontTypes.sayFont());
		descriptionTextBox.lineSpacing = 8;
		UI.setTopLeft(button.actor, 10, 10);
		UI.setBottomLeft(closeButton.actor, 10, 10);
		button.addOnClickListener(this.onButtonClick);
		closeButton.addOnClickListener(this.close);
		button.hide();
		closeButton.hide();
		UserInterface.ui.addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			if(!isOpen) return;
			drawItemText(g);
		});
	}
	
	// Opens a popup with the item
	// 'scope' is the reason why the popup was opened, and dictates what happens when you click
	public function open(item : Item, scope : Int){
		currentlyOpenItem = item;
		currentScope = scope;
		background = new ImageX(backgroundBitmap, "Inventory");
		background.centerOnScreen();
		iconFrame = new ImageX(iconFrameBitmap, "Inventory");
		iconFrame.setXY(constants.itemX, constants.itemY);
		var path = "icons/" + item.imageName + ".png";
		icon = new ImageX(path, "Inventory");
		icon.setXY(iconFrame.getX() + 1, iconFrame.getY() + 1);
		button.show();
		closeButton.show();
		button.unmarkAsGrayed();
		if(scope == scopes.Use_Item && item.onUse == null){
			button.markAsGrayed();
		}
		var itemDescription = Item.generateDescription(item);
		descriptionTextBox.setText(itemDescription);
		descriptionTextBox.startDrawing();
		isOpen = true;
	}
	
	public function close(){
		isOpen = false;
		currentlyOpenItem = null;
		background.kill();
		iconFrame.kill();
		icon.kill();
		button.hide();
		closeButton.hide();
		descriptionTextBox.stopDrawing();
	}
	
	public function onButtonClick(){
		if(!isOpen) return;	// Not sure if required, but prevents potential bugs
		if(currentScope == scopes.Use_Item){
			if(Game.currentScene == Game.scenes.Battlefield_Scene){
				currentlyOpenItem.onUse(Battlefield.currentlyActiveUnit);
				Item.consumeItem(currentlyOpenItem, currentlyOpenInventory);
				InventoryUI.closeInventory();
				InventoryUI.openInventory(currentlyOpenInventory, currentInventoryScope);
			}
		} else if(currentScope == scopes.Sell_Item){
			trace("Selling...");
			if(currentlyOpenItem == null){
				trace("Null item!");
			}
			if(currentlyOpenInventory == null){
				trace("Null inventory!");
			}
			Item.consumeItem(currentlyOpenItem, currentlyOpenInventory);
			trace("Consumed. Closing inventory...");
			InventoryUI.closeInventory();
			trace("Ok. Reopening it now...");
			InventoryUI.openInventory(currentlyOpenInventory, currentInventoryScope);
			trace("Ok, reopened inventory");
		}
	}
	
	public function drawItemText(g : G){
		g.setFont(FontTypes.itemTitleCommon());
		g.drawString(currentlyOpenItem.name, constants.titleX, constants.titleY);
	}
	
	
}

class InventoryUI
{
	
	public static var constants = {
		x		 			: 40,
		y		 			: 35,
		height		 		: 250,
		width		 		: 400,
		itemWidth	 		: 34,
		itemHeight	 		: 34,
		itemSpacingH 		: 5,
		itemSpacingV 		: 6,	
	}
	
	public static var scopes = {
		Shop_Inventory : 1,
		Battlefield_Inventory : 2,
		Sell_Inventory : 3
	}
	
	
	
	public static var isOpen 		= false;
	public static var backgroundBitmap 			: BitmapData;
	public static var iconFrameBitmap			: BitmapData;
	public static var inventoryBackground 		: ImageX;
	public static var iconFrames		  		: Matrix<ImageX>;	// Just the visuals, I will replace it later to be inside the inventory background maybe
	public static var iconImages		  		: Matrix<ImageX>;	// Just the visuals, I will replace it later to be inside the inventory background maybe
	public static var currentlyOpenInventory 	: Inventory<Item>;	// Item currently in popup
	public static var popup						: ItemPopupUI;
	public static var currentScope				: Int;
	
	
	
	
	// Once per scene
	// Adds a click listener, so, you know
	// NOTE: The scene *needs* an Inventory layer!!!
	public static function init(){
		backgroundBitmap	= getExternalImage("ui/InventoryBackground.png");
		iconFrameBitmap		= getExternalImage("ui/IconFrame.png");
		popup				= new ItemPopupUI();
		UserInterface.ui.addMousePressedListener(function(list:Array<Dynamic>):Void{
			if(!isOpen) return;
			if(popup.isOpen) return;
			var itemClickedCoordinates = getClickedItemByMouseCoordinates();
			if(itemClickedCoordinates == null) return;
			var x = itemClickedCoordinates.x;
			var y = itemClickedCoordinates.y;
			if(currentlyOpenInventory.get(y, x) == null) return;	// If no item there, return
			if(currentScope == scopes.Battlefield_Inventory){
				Battlefield.onClickOnInventoryItem(itemClickedCoordinates.x, itemClickedCoordinates.y);
			} else if(currentScope == scopes.Sell_Inventory){
				openPopup(currentlyOpenInventory.get(y, x), popup.scopes.Sell_Item);
			}
		});
		UserInterface.ui.addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			if(!isOpen) return;
			if(popup.isOpen) return;
			//if(currentScope != scopes.Shop_Inventory) return;
			drawPrices(g);
		});
	}
	
	// This is NON-RESPONSIVE : it does not scale with screen size
	// Fix that!! Could also use a refactor
	public static function openInventory(inv : Inventory<Item>, scope : Int){
		isOpen = true;
		currentScope = scope;
		currentlyOpenInventory = inv;
		inventoryBackground = new ImageX(backgroundBitmap, "Inventory");
		inventoryBackground.centerOnScreen();
		iconFrames = new Matrix(inv.nRows, inv.nCols);
		iconImages = new Matrix(inv.nRows, inv.nCols);
		for(r in 0...inv.nRows){
			for(c in 0...inv.nCols){
				iconFrames.set(r, c, new ImageX(iconFrameBitmap, "Inventory"));
				iconFrames.get(r, c).setX(constants.x + (c+1) * constants.itemSpacingH + c * constants.itemWidth);
				iconFrames.get(r, c).setY(constants.y + (r+1) * constants.itemSpacingV + r * constants.itemHeight);
				if(inv.get(r, c) != null){				
					var path = "icons/" + inv.get(r, c).imageName + ".png";
					iconImages.set(r, c, new ImageX(path, "Inventory"));
					iconImages.get(r, c).setX(constants.x + (c+1) * constants.itemSpacingH + c * constants.itemWidth);
					iconImages.get(r, c).setY(constants.y + (r+1) * constants.itemSpacingV + r * constants.itemHeight);
				}
			}
		}
	}
	
	public static function closeInventory(){
		trace("");
		trace("");
		trace("Closing inventory");
		currentlyOpenInventory = null;
		isOpen = false;
		inventoryBackground.kill();
		trace("Aight lets see...");
		for(r in 0...iconFrames.nRows){
			for(c in 0...iconFrames.nCols){
				iconFrames.get(r, c).kill();
				if(iconImages.get(r, c) != null){
					trace("  Killing this bitch: " + r +", " + c);
					iconImages.get(r, c).kill();
					trace("  Bitch killed.");
				}
					
			}
		}
		trace("Closing popup");
		if(popup.isOpen){
			popup.close();
		}
		trace("Inventory closing looks good to me.");
		iconFrames = null;
	}
	
	
	public static function openPopup(item : Item, scope : Int){
		popup.open(item, scope);
		popup.currentlyOpenInventory = currentlyOpenInventory;
		popup.currentInventoryScope = currentScope;
	}
	
	
	private static function getClickedItemByMouseCoordinates() : Vector2Int{
		var mouseXScreen = getMouseX() - getScreenX();
		var mouseYScreen = getMouseY() - getScreenY();
		if(mouseXScreen < constants.x + constants.itemSpacingH) return null;
		if(mouseXScreen > constants.x + (constants.itemSpacingH + constants.itemWidth) * iconFrames.nCols) return null;
		if(mouseYScreen < constants.y + constants.itemSpacingV) return null;
		if(mouseYScreen > constants.y + (constants.itemSpacingV + constants.itemHeight) * iconFrames.nRows) return null;
		var atWhichX = Math.floor(( mouseXScreen - constants.x) / (constants.itemWidth + constants.itemSpacingH));
		var atWhichY = Math.floor(( mouseYScreen - constants.y) / (constants.itemHeight + constants.itemSpacingV));
		return new Vector2Int(atWhichX, atWhichY);
	}
	
	private static function drawPrices(g : G){
		g.setFont(FontTypes.priceFont());
		var item;
		for(r in 0...currentlyOpenInventory.nRows){
			for(c in 0...currentlyOpenInventory.nCols){
				item = currentlyOpenInventory.get(r, c);
				if(item != null){
					var x = constants.x + (c+1) * constants.itemSpacingH + c * constants.itemWidth;
					var y = constants.y + (r+1) * constants.itemSpacingV + r * constants.itemHeight;
					g.drawString(item.price + "", x, y);
				}
			}
		}
		
	}
}




