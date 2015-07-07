//
//  CCRepeat9Sprite.h
//  CocosBuilder
//
//  Created by zhengle on 15-3-12.
//
//

#import "cocos2d.h"

#pragma mark Enums

typedef enum{
    RepeatNone = 0,
    RepeatHorizon,
    RepeatVertical,
    RepeatAll
} RepeatEnum;

typedef enum{
    Left = 0,
    Right,
    Top,
    Bottom,
    All
} RepeatEdge;

#pragma mark -
#pragma mark CCRepeatNode
@interface CCRepeatNode : CCNode <CCRGBAProtocol>
{
@private
    CCTexture2D* _texture;
    CGRect _rect;
    RepeatEnum _repeatMode;
    bool _needUpdate;
    bool _rotated;
}

@property(nonatomic, retain) CCTexture2D* texture;
@property(nonatomic, assign) CGRect rect;
@property(nonatomic, assign) RepeatEnum repeatMode;
@property(nonatomic, assign) bool needUpdate;
@property(nonatomic, assign) bool rotated;

- (id) init:(RepeatEnum)mode texture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(bool)rotated;
- (void) dealloc;
- (void) addSpriteWithScaleX:(float)scaleX scaleY:(float)scaleY position:(CGPoint)position;

+ (CCRepeatNode*) create:(RepeatEnum) mode withTexture:(CCTexture2D*) texture Rect:(CGRect)tRect Rotated:(bool)rotated;
@end

#pragma mark -
#pragma mark CCRepeat9Sprite

@interface CCRepeat9Sprite : CCNode <CCRGBAProtocol>
{
    bool _spritesGenerated;
    CGRect _spriteRect;
    bool   _spriteFrameRotated;
    CGRect _capInsetsInternal;
    bool _positionsAreDirty;
    
    CCSpriteBatchNode* _scale9Image;
    CCRepeatNode* _top;
    CCRepeatNode* _left;
    CCRepeatNode* _right;
    CCRepeatNode* _bottom;
    
    CCSprite* _topLeft;
    CCSprite* _topRight;
    CCSprite* _centre;
    CCSprite* _bottomLeft;
    CCSprite* _bottomRight;
    
    RepeatEnum _leftMode;
    RepeatEnum _topMode;
    RepeatEnum _rightMode;
    RepeatEnum _bottomMode;
    
    CGSize _originalSize;
    CGSize _preferedSize;
    
    CGRect _capInsets;
    float _insetLeft;
    float _insetTop;
    float _insetRight;
    float _insetBottom;
    
    // texture RGBA
    GLubyte             _opacity;
    ccColor3B           _color;
    BOOL                _opacityModifyRGB;
}

/** Original sprite's size. */
@property(nonatomic, readonly, assign) CGSize originalSize;
/** Prefered sprite's size. By default the prefered size is the original size. */

//if the preferredSize component is given as -1, it is ignored
@property (nonatomic, assign) CGSize preferedSize;
/**
 * The end-cap insets.
 * On a non-resizeable sprite, this property is set to CGRect::ZERO; the sprite
 * does not use end caps and the entire sprite is subject to stretching.
 */
@property(nonatomic, assign) CGRect capInsets;
/** Sets the left side inset */
@property(nonatomic, assign) float insetLeft;
/** Sets the top side inset */
@property(nonatomic, assign) float insetTop;
/** Sets the right side inset */
@property(nonatomic, assign) float insetRight;
/** Sets the bottom side inset */
@property(nonatomic, assign) float insetBottom;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, readwrite) GLubyte opacity;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, readwrite) ccColor3B color;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, getter = doesOpacityModifyRGB) BOOL opacityModifyRGB;

@property(nonatomic, assign) RepeatEnum leftMode;
@property(nonatomic, assign) RepeatEnum rightMode;
@property(nonatomic, assign) RepeatEnum topMode;
@property(nonatomic, assign) RepeatEnum bottomMode;

-(bool) leftRepeat;
-(void) setLeftRepeat:(bool)val;
-(bool) rightRepeat;
-(void) setRightRepeat:(bool)val;
-(bool) topRepeat;
-(void) setTopRepeat:(bool)val;
-(bool) bottomRepeat;
-(void) setBottomRepeat:(bool)val;

-(void) dealloc;

//+ (CCRepeat9Sprite*) create;
//+ (CCRepeat9Sprite*) create:(NSString*)file rect:(CGRect)rect  capInsets:(CGRect)capInsets;
//+ (CCRepeat9Sprite*) create:(CGRect)capInsets file:(NSString*)file;
//+ (CCRepeat9Sprite*) create:(NSString*)file rect:(CGRect)rect;
//+ (CCRepeat9Sprite*) create:(NSString*)file;
//+ (CCRepeat9Sprite*) createWithSpriteFrame:(CCSpriteFrame*)spriteFrame;
//+ (CCRepeat9Sprite*) createWithSpriteFrame:(CCSpriteFrame*)spriteFrame capInsets:(CGRect)capInsets;
//+ (CCRepeat9Sprite*) createWithSpriteFrameName:(NSString*)spriteFrameName;
//+ (CCRepeat9Sprite*) createWithSpriteFrameName:(NSString*)spriteFrameName capInsets:(CGRect)capInsets;

- (id) initWithFile:(NSString*)file rect:(CGRect)rect capInsets:(CGRect)capInsets;
- (id) initWithFile:(NSString*)file rect:(CGRect)rect;
- (id) initWithFile:(NSString *)file capInsets:(CGRect)capInsets;
- (id) initWithFile:(NSString*) file;
- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame capInsets:(CGRect)capInsets;
- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame;
- (id) initWithSpriteFrameName:(NSString*)spriteFrameName capInsets:(CGRect)capInsets;
- (id) initWithSpriteFrameName:(NSString*)spriteFrameName;
- (id) init;
- (id) initWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect capInsets:(CGRect)capInsets;
- (id) initWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect rotated:(bool)rotated capInsets:(CGRect)capInsets;
- (void) updateWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect rotated:(bool)rotated capInsets:(CGRect)capInsets;
- (void) setSpriteFrame:(CCSpriteFrame*)spriteFrame;
- (CCRepeat9Sprite*) resizableSpriteWithCapInsets:(CGRect)capInsets;

// overrides
-(void) setContentSize:(CGSize)size;

-(void) visit;
-(void) setOpacityModifyRGB:(bool) bValue;
-(bool) isOpacityModifyRGB;
-(void) setOpacity:(GLubyte)opacity;
-(void) setColor:(ccColor3B)color;
//-(void) updateDisplayedOpacity:(GLubyte)parentOpacity;
//-(void) updateDisplayedColor:(ccColor3B) parentColor;

-(bool) isRepeatEdge:(RepeatEdge) edge;
-(void) setRepeatMode:(RepeatEnum) mode;
-(void) setRepeatModeToEdge:(bool)repeat edge:(RepeatEdge)edge;

@end
