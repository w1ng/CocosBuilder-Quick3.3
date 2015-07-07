//
//  CCRepeat9Sprite.m
//  CocosBuilder
//
//  Created by zhengle on 15-3-12.
//
//

#import "CCRepeat9Sprite.h"

#pragma mark CCRepeatNode
@interface CCRepeatNode ()
- (void)updateRepeatNode;
@end

@implementation CCRepeatNode

@synthesize displayedColor;
@synthesize opacity;
@synthesize cascadeColorEnabled;
@synthesize color;
@synthesize displayedOpacity;
@synthesize cascadeOpacityEnabled;

@synthesize texture=_texture;
@synthesize rect=_rect;
@synthesize repeatMode=_repeatMode;
@synthesize needUpdate=_needUpdate;
@synthesize rotated=_rotated;

- (id) init:(RepeatEnum)mode texture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(bool)isRotated
{
    
    if ((self = [super init])) {
        [self setCascadeColorEnabled:YES];
        [self setCascadeOpacityEnabled:YES];
        self.texture = texture;
        self.rect = rect;
        [self setContentSize:rect.size];
        self.repeatMode = mode;
        self.rotated = isRotated;
    }
    
    return self;
}

- (void) dealloc
{
    if (_texture) [_texture release];
    [super dealloc];
}

- (void) setContentSize:(CGSize)contentSize
{
    CGSize size = [self contentSize];
    if (size.height == contentSize.height && size.width == contentSize.width)
    {
        return;
    }
    
    [super setContentSize:contentSize];
    self.needUpdate = YES;
}

- (void) setRepeatMode:(RepeatEnum)repeatMode
{
    if (self.repeatMode == repeatMode) {
        return;
    }
    
    _repeatMode = repeatMode;
    self.needUpdate = YES;
}

+ (CCRepeatNode*) create:(RepeatEnum)mode withTexture:(CCTexture2D*)texture rect:(CGRect)tRect rotated:(bool)rotated
{
    CCRepeatNode* rnode = [CCRepeatNode alloc];
    if ([rnode init:mode texture:texture rect:tRect rotated:rotated]) {
        [rnode autorelease];
        return rnode;
    }else{
        [rnode release];
        return nil;
    }
}

- (void) addSpriteWithScaleX:(float)scaleX scaleY:(float)scaleY position:(CGPoint)position
{
    CCSprite* sprite = [[CCSprite alloc] initWithTexture:self.texture rect:self.rect rotated:self.rotated];
    [self addChild:sprite];
    sprite.scaleX = scaleX;
    sprite.scaleY = scaleY;
    sprite.anchorPoint = ccp(0, 0);
    sprite.position = position;
}

- (void) updateRepeatNode
{
    [self removeAllChildrenWithCleanup:YES];
    float scaleX = 1.0;
    float scaleY = 1.0;
    int repeatTimes = 1;
    CGSize size = self.contentSize;
    
    switch (self.repeatMode) {
        case RepeatHorizon:
        {
            scaleY = size.height / self.rect.size.height;
            repeatTimes = floor(size.width / self.rect.size.width) + 1;
            scaleX= size.width/(self.rect.size.width * repeatTimes);
            break;
        }
        case RepeatVertical:
        {
            scaleX = size.width / self.rect.size.width;
            repeatTimes = floor(size.height / self.rect.size.height) + 1;
            scaleY = size.height/(self.rect.size.height * repeatTimes);
            break;
        }
        default:
            scaleY = size.height / self.rect.size.height;
            scaleX = size.width / self.rect.size.width;
            break;
    }
    
    CGPoint p = ccp(0, 0);
    for (int index = 0; index < repeatTimes; index++) {
        //设置偏移量
        if(index > 0){
            if (self.repeatMode == RepeatHorizon){
                p.x = self.rect.size.width * scaleX + p.x;
            }else if(self.repeatMode == RepeatVertical){
                p.y = self.rect.size.height * scaleY + p.y;
            }
        }
        
        [self addSpriteWithScaleX:scaleX scaleY:scaleY position:p];
    }
}

- (void) visit
{
    if (self.needUpdate) {
        [self updateRepeatNode];
        self.needUpdate = NO;
    }
    [super visit];
}

@end

enum positions
{
    pCentre = 0,
    pTop,
    pLeft,
    pRight,
    pBottom,
    pTopRight,
    pTopLeft,
    pBottomRight,
    pBottomLeft
};

#pragma mark -
#pragma mark CCRepeat9Sprite
@interface CCRepeat9Sprite ()
- (void) updateCapInset;
- (void) updatePositions;
@end

@implementation CCRepeat9Sprite

@synthesize displayedColor;
@synthesize opacity=_opacity;
@synthesize cascadeColorEnabled;
@synthesize color=_color;
@synthesize displayedOpacity;
@synthesize cascadeOpacityEnabled;

@synthesize originalSize=_originalSize;
@synthesize preferedSize=_preferedSize;
@synthesize capInsets=_capInsets;
@synthesize insetTop=_insetTop;
@synthesize insetBottom=_insetBottom;
@synthesize insetLeft=_insetLeft;
@synthesize insetRight=_insetRight;
@synthesize leftMode=_leftMode;
@synthesize rightMode=_rightMode;
@synthesize topMode=_topMode;
@synthesize bottomMode=_bottomMode;

@synthesize opacityModifyRGB=_opacityModifyRGB;

-(void) dealloc
{
    if(_topLeft) [_topLeft release];
    if(_top) [_top release];
    if(_topRight) [_topRight release];
    if(_left) [_left release];
    if(_centre) [_centre release];
    if(_right) [_right release];
    if(_bottomLeft) [_bottomLeft release];
    if(_bottom) [_bottom release];
    if(_bottomRight) [_bottomRight release];
    if(_scale9Image) [_scale9Image release];
    
    [super dealloc];
}

#pragma mark CCRepeat9Sprite Private Methods
-(void) setInsetTop:(float)val
{
    _insetTop = val;
    [self updateCapInset];
}

-(void) setInsetBottom:(float)val
{
    _insetBottom = val;
    [self updateCapInset];
}

-(void) setInsetLeft:(float)val
{
    _insetLeft = val;
    [self updateCapInset];
}

-(void) setInsetRight:(float)val
{
    _insetRight = val;
    [self updateCapInset];
}

-(void) setTopMode:(RepeatEnum)val
{
    _topMode = val;
    [self updateCapInset];
}

-(void) setBottomMode:(RepeatEnum)val
{
    _bottomMode = val;
    [self updateCapInset];
}

-(void) setLeftMode:(RepeatEnum)val
{
    _leftMode = val;
    [self updateCapInset];
}

-(void) setRightMode:(RepeatEnum)val
{
    _rightMode = val;
    [self updateCapInset];
}

-(bool) leftRepeat
{
    return [self isRepeatEdge:Left];
}

-(void) setLeftRepeat:(bool)val
{
    [self setRepeatModeToEdge:val edge:Left];
}

-(bool) rightRepeat
{
    return [self isRepeatEdge:Right];
}

-(void) setRightRepeat:(bool)val
{
    [self setRepeatModeToEdge:val edge:Right];
}

-(bool) topRepeat
{
    return [self isRepeatEdge:Top];
}

-(void) setTopRepeat:(bool)val
{
    [self setRepeatModeToEdge:val edge:Top];
}

-(bool) bottomRepeat
{
    return [self isRepeatEdge:Bottom];
}

-(void) setBottomRepeat:(bool)val
{
    [self setRepeatModeToEdge:val edge:Bottom];
}

-(void) setCapInsets:(CGRect)capInsets
{
    CGSize contentSize = self.contentSize;
    [self updateWithBatchNode:_scale9Image rect:_spriteRect rotated:_spriteFrameRotated capInsets:capInsets];
    self.contentSize = contentSize;
}

- (void) updateCapInset
{
    CGRect insets;
    if (_insetLeft == 0 && _insetTop == 0 && _insetRight == 0 && _insetBottom == 0)
    {
        insets = CGRectZero;
    }
    else
    {
        insets = CGRectMake(_insetLeft,
                            _insetTop,
                            _spriteRect.size.width-_insetLeft-_insetRight,
                            _spriteRect.size.height-_insetTop-_insetBottom);
        NSLog(@"left, top, right, bottom = %.2f, %.2f, %.2f, %.2f", _insetLeft, _insetTop, _insetRight, _insetBottom);
    }
    [self setCapInsets:insets];
}

- (void) updatePositions
{
    // Check that instances are non-nullptr
    if(!((_topLeft) &&
         (_topRight) &&
         (_bottomRight) &&
         (_bottomLeft) &&
         (_centre))) {
        // if any of the above sprites are nullptr, return
        return;
    }
    
    CGSize size = self.contentSize;
    
    float sizableWidth = size.width - _topLeft.contentSize.width - _topRight.contentSize.width;
    float sizableHeight = size.height - _topLeft.contentSize.height - _bottomRight.contentSize.height;
    float horizontalScale = sizableWidth/_centre.contentSize.width;
    float verticalScale = sizableHeight/_centre.contentSize.height;
    
    [_centre setScaleX:horizontalScale];
    [_centre setScaleY:verticalScale];
    
    float rescaledWidth = _centre.contentSize.width * horizontalScale;
    float rescaledHeight = _centre.contentSize.height * verticalScale;
    
    float leftWidth = _bottomLeft.contentSize.width;
    float bottomHeight = _bottomLeft.contentSize.height;
    
    [_bottomLeft setAnchorPoint:ccp(0,0)];
    [_bottomRight setAnchorPoint:ccp(0,0)];
    [_topLeft setAnchorPoint:ccp(0,0)];
    [_topRight setAnchorPoint:ccp(0,0)];
    [_left setAnchorPoint:ccp(0,0)];
    [_right setAnchorPoint:ccp(0,0)];
    [_top setAnchorPoint:ccp(0,0)];
    [_bottom setAnchorPoint:ccp(0,0)];
    [_centre setAnchorPoint:ccp(0,0)];
    
    // Position corners
    [_bottomLeft setPosition:ccp(0,0)];
    [_bottomRight setPosition:ccp(leftWidth+rescaledWidth,0)];
    [_topLeft setPosition:ccp(0, bottomHeight+rescaledHeight)];
    [_topRight setPosition:ccp(leftWidth+rescaledWidth, bottomHeight+rescaledHeight)];
    
    // Scale and position borders
    [_left setPosition:ccp(0, bottomHeight)];
    [_left setContentSize:CGSizeMake(_bottomLeft.contentSize.width, sizableHeight)];
    
    [_right setPosition:ccp(leftWidth+rescaledWidth,bottomHeight)];
    [_right setContentSize:CGSizeMake(_bottomRight.contentSize.width, sizableHeight)];
    
    [_bottom setPosition:ccp(leftWidth,0)];
    [_bottom setContentSize:CGSizeMake(sizableWidth, _bottomLeft.contentSize.height)];
    
    [_top setPosition:ccp(leftWidth,bottomHeight+rescaledHeight)];
    [_top setContentSize:CGSizeMake(sizableWidth, _topLeft.contentSize.height)];
    
    // Position centre
    [_centre setPosition:ccp(leftWidth, bottomHeight)];
}

#pragma mark CCRepeat9Sprite Override Methods
- (void) setPreferedSize:(CGSize)preferedSize
{
    _preferedSize    = preferedSize;
    self.contentSize = preferedSize;
}

-(void) setContentSize:(CGSize)size
{
    [super setContentSize:size];
    _positionsAreDirty = YES;
}

-(void) visit
{
    if (_positionsAreDirty) {
        [self updatePositions];
        _positionsAreDirty = NO;
    }
    
    [super visit];
}

-(void) setOpacityModifyRGB:(bool) var
{
    if (!_scale9Image)
    {
        return;
    }
    _opacityModifyRGB = var;
    
    for (id child in _scale9Image.children) {
        [child setOpacityModifyRGB:_opacityModifyRGB];
    }
}

-(bool) isOpacityModifyRGB
{
    return _opacityModifyRGB;
}

-(void) setOpacity:(GLubyte)opacity
{
    if (!_scale9Image)
    {
        return;
    }
    _opacity = opacity;
    
    for(CCNode<CCRGBAProtocol>* child in _scale9Image.children){
        [child setOpacity:opacity];
    }
}

-(void) setColor:(ccColor3B)color
{
    if (!_scale9Image)
    {
        return;
    }
    _color = color;
    
    for(CCNode<CCRGBAProtocol>* child in _scale9Image.children){
        [child setColor:color];
    }
    
    for(CCNode<CCRGBAProtocol>* child in self.children){
        if (((CCSpriteBatchNode*)child) == _scale9Image) continue;
        [child setColor:color];
    }
}

//-(void) updateDisplayedOpacity:(GLubyte)parentOpacity
//{
//    if (!_scale9Image)
//    {
//        return;
//    }
//    [super updateDisplayedOpacity:parentOpacity];
//    
//    for(id child in _scale9Image.children){
//        [child updateDisplayedOpacity:parentOpacity];
//    }
//}

//-(void) updateDisplayedColor:(ccColor3B) parentColor
//{
//    if (!_scale9Image)
//    {
//        return;
//    }
//    [super updateDisplayedColor:parentColor];
//    
//    for(id child in _scale9Image.children){
//        [child updateDisplayedColor:parentColor];
//    }
//}

-(bool) isRepeatEdge:(RepeatEdge) edge
{
    switch (edge) {
        case Left:
            return _leftMode != RepeatNone;
        case Right:
            return _rightMode != RepeatNone;
        case Top:
            return _topMode != RepeatNone;
        case Bottom:
            return _bottomMode != RepeatNone;
        default:
            return false;
    }
}

-(void) setRepeatMode:(RepeatEnum) mode
{
    bool v = false;
    bool h = false;
    switch (mode) {
        case RepeatAll:
            v = true;
            h = true;
            break;
        case RepeatVertical:
            v = true;
            h = false;
            break;
        case RepeatHorizon:
            v = false;
            h = true;
            break;
        default:
            break;
    }
    
    [self setRepeatModeToEdge:v edge:Left];
    [self setRepeatModeToEdge:v edge:Right];
    [self setRepeatModeToEdge:h edge:Top];
    [self setRepeatModeToEdge:h edge:Bottom];
}

-(void) setRepeatModeToEdge:(bool)repeat edge:(RepeatEdge)edge
{
    switch (edge) {
        case All:
            [self setRepeatMode:(repeat ? RepeatAll : RepeatNone)];
            break;
        case Left:
            _leftMode = (repeat ? RepeatVertical : RepeatNone);
            _left.repeatMode = _leftMode;
            break;
        case Right:
            _rightMode = (repeat ? RepeatVertical : RepeatNone);
            _right.repeatMode = _rightMode;
            break;
        case Top:
            _topMode = (repeat ? RepeatHorizon : RepeatNone);
            _top.repeatMode = _topMode;
            break;
        case Bottom:
            _bottomMode = (repeat ? RepeatHorizon : RepeatNone);
            _bottom.repeatMode = _bottomMode;
            break;
        default:
            break;
    }
}

- (void) updateWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect rotated:(bool)rotated capInsets:(CGRect)capInsets
{
    GLubyte opacity = _opacity;
    ccColor3B color = _color;
    
    // Release old sprites
    [self removeAllChildrenWithCleanup:YES];
    
    [_centre         release];
    [_top            release];
    [_topLeft        release];
    [_topRight       release];
    [_left           release];
    [_right          release];
    [_bottomLeft     release];
    [_bottom         release];
    [_bottomRight    release];
    
    if (_scale9Image != batchnode)
    {
        [_scale9Image release];
        _scale9Image = [batchnode retain];
    }
    
    [_scale9Image removeAllChildrenWithCleanup:YES];
    
    _capInsets          = capInsets;
    _spriteFrameRotated = rotated;
    
    // If there is no given rect
    if (CGRectEqualToRect(rect, CGRectZero))
    {
        // Get the texture size as original
        CGSize textureSize  = [[[_scale9Image textureAtlas] texture] contentSize];
        
        rect                = CGRectMake(0, 0, textureSize.width, textureSize.height);
    }
    
    // Set the given rect's size as original size
    _spriteRect          = rect;
    _originalSize       = rect.size;
    _preferedSize       = _originalSize;
    _capInsetsInternal  = capInsets;
    
    // Get the image edges
    float l = rect.origin.x;
    float t = rect.origin.y;
    float h = rect.size.height;
    float w = rect.size.width;
    
    // If there is no specified center region
    if (CGRectEqualToRect(_capInsetsInternal, CGRectZero))
    {
        // Apply the 3x3 grid format
        if (rotated)
        {
            _capInsetsInternal = CGRectMake(l+h/3, t+w/3, w/3, h/3);
        }
        else
        {
            _capInsetsInternal  = CGRectMake(l+w/3, t+h/3, w/3, h/3);
        }
    }
    
    //
    // Set up the image
    //
    
    
    if (rotated)
    {
        // Sprite frame is rotated
        
        // Centre
        _centre      = [[CCSprite alloc] initWithTexture:_scale9Image.texture rect:_capInsetsInternal rotated:rotated];
        [_scale9Image addChild:_centre z:0 tag:pCentre];
        
        // Bottom
        _bottom         = [[CCRepeatNode alloc]
                           init:_bottomMode
                           texture:_scale9Image.texture
                           rect:CGRectMake(l,
                                           _capInsetsInternal.origin.y,
                                           _capInsetsInternal.size.width,
                                           _capInsetsInternal.origin.x - l)
                           rotated:rotated
                           ];
        [self addChild:_bottom z:1 tag:pBottom];
        
        // Top
        _top      = [[CCRepeatNode alloc]
                     init:_topMode
                     texture:_scale9Image.texture
                     rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.height,
                                     _capInsetsInternal.origin.y,
                                     _capInsetsInternal.size.width,
                                     h - _capInsetsInternal.size.height - (_capInsetsInternal.origin.x - l))
                     rotated:rotated
                     ];
        [self addChild:_top z:1 tag:pTop];
        
        // Right
        _right        = [[CCRepeatNode alloc]
                         init:_rightMode
                         texture:_scale9Image.texture
                         rect:CGRectMake(_capInsetsInternal.origin.x,
                                         _capInsetsInternal.origin.y+_capInsetsInternal.size.width,
                                         w - (_capInsetsInternal.origin.y-t)-_capInsetsInternal.size.width,
                                         _capInsetsInternal.size.height)
                         rotated:rotated
                         ];
        [self addChild:_right z:1 tag:pRight];
        
        // Left
        _left       = [[CCRepeatNode alloc]
                       init:_leftMode
                       texture:_scale9Image.texture
                       rect:CGRectMake(_capInsetsInternal.origin.x,
                                       t,
                                       _capInsetsInternal.origin.y - t,
                                       _capInsetsInternal.size.height)
                       rotated:rotated
                       ];
        [self addChild:_left z:1 tag:pLeft];
        
        // Top _right
        _topRight     = [[CCSprite alloc]
                         initWithTexture:_scale9Image.texture
                         rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.height,
                                         _capInsetsInternal.origin.y + _capInsetsInternal.size.width,
                                         w - (_capInsetsInternal.origin.y-t)-_capInsetsInternal.size.width,
                                         h - _capInsetsInternal.size.height - (_capInsetsInternal.origin.x - l))
                         rotated:rotated
                         ];
        [_scale9Image addChild:_topRight z:2 tag:pTopRight];
        
        // Top _left
        _topLeft    = [[CCSprite alloc]
                       initWithTexture:_scale9Image.texture
                       rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.height,
                                       t,
                                       _capInsetsInternal.origin.y - t,
                                       h - _capInsetsInternal.size.height - (_capInsetsInternal.origin.x - l))
                       rotated:rotated
                       ];
        [_scale9Image addChild:_topLeft z:2 tag:pTopLeft];
        
        // Bottom _right
        _bottomRight  = [[CCSprite alloc]
                         initWithTexture:_scale9Image.texture
                         rect:CGRectMake(l,
                                         _capInsetsInternal.origin.y + _capInsetsInternal.size.width,
                                         w - (_capInsetsInternal.origin.y-t)-_capInsetsInternal.size.width,
                                         _capInsetsInternal.origin.x - l)
                         rotated:rotated
                         ];
        [_scale9Image addChild:_bottomRight z:2 tag:pBottomRight];
        
        // Bottom _left
        _bottomLeft     = [[CCSprite alloc]
                           initWithTexture:_scale9Image.texture
                           rect:CGRectMake(l,
                                           t,
                                           _capInsetsInternal.origin.y - t,
                                           _capInsetsInternal.origin.x - l)
                           rotated:rotated
                           ];
        [_scale9Image addChild:_bottomLeft z:2 tag:pBottomLeft];
    }
    else
    {
        // Sprite frame is not rotated
        
        // Centre
        _centre      = [[CCSprite alloc] initWithTexture:_scale9Image.texture rect:_capInsetsInternal rotated:rotated];
        [_scale9Image addChild:_centre z:0 tag:pCentre];
        
        // Top
        _top         = [[CCRepeatNode alloc]
                        init:_topMode
                        texture:_scale9Image.texture
                        rect:CGRectMake(_capInsetsInternal.origin.x,
                                        t,
                                        _capInsetsInternal.size.width,
                                        _capInsetsInternal.origin.y - t)
                        rotated:rotated
                        ];
        [self addChild:_top z:1 tag:pTop];
        
        // Bottom
        _bottom      = [[CCRepeatNode alloc]
                        init:_bottomMode
                        texture:_scale9Image.texture
                        rect:CGRectMake(_capInsetsInternal.origin.x,
                                        _capInsetsInternal.origin.y + _capInsetsInternal.size.height,
                                        _capInsetsInternal.size.width,
                                        h - (_capInsetsInternal.origin.y - t + _capInsetsInternal.size.height))
                        rotated:rotated
                        ];
        [self addChild:_bottom z:1 tag:pBottom];
        
        // Left
        _left        = [[CCRepeatNode alloc]
                        init:_leftMode
                        texture:_scale9Image.texture
                        rect:CGRectMake(l,
                                        _capInsetsInternal.origin.y,
                                        _capInsetsInternal.origin.x - l,
                                        _capInsetsInternal.size.height)
                        rotated:rotated
                        ];
        [self addChild:_left z:1 tag:pLeft];
        
        // Right
        _right       = [[CCRepeatNode alloc]
                        init:_rightMode
                        texture:_scale9Image.texture
                        rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.width,
                                        _capInsetsInternal.origin.y,
                                        w - (_capInsetsInternal.origin.x - l + _capInsetsInternal.size.width),
                                        _capInsetsInternal.size.height)
                        rotated:rotated
                        ];
        [self addChild:_right z:1 tag:pRight];
        
        // Top _left
        _topLeft     = [[CCSprite alloc]
                        initWithTexture:_scale9Image.texture
                        rect:CGRectMake(l,
                                        t,
                                        _capInsetsInternal.origin.x - l,
                                        _capInsetsInternal.origin.y - t)
                        rotated:rotated
                        ];
        [_scale9Image addChild:_topLeft z:2 tag:pTopLeft];
        
        // Top _right
        _topRight    = [[CCSprite alloc]
                        initWithTexture:_scale9Image.texture
                        rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.width,
                                        t,
                                        w - (_capInsetsInternal.origin.x - l + _capInsetsInternal.size.width),
                                        _capInsetsInternal.origin.y - t)
                        rotated:rotated
                        ];
        [_scale9Image addChild:_topRight z:2 tag:pTopRight];
        
        // Bottom _left
        _bottomLeft  = [[CCSprite alloc]
                        initWithTexture:_scale9Image.texture
                        rect:CGRectMake(l,
                                        _capInsetsInternal.origin.y + _capInsetsInternal.size.height,
                                        _capInsetsInternal.origin.x - l,
                                        h - (_capInsetsInternal.origin.y - t + _capInsetsInternal.size.height))
                        rotated:rotated
                        ];
        [_scale9Image addChild:_bottomLeft z:2 tag:pBottomLeft];
        
        // Bottom _right
        _bottomRight     = [[CCSprite alloc]
                            initWithTexture:_scale9Image.texture
                            rect:CGRectMake(_capInsetsInternal.origin.x + _capInsetsInternal.size.width,
                                            _capInsetsInternal.origin.y + _capInsetsInternal.size.height,
                                            w - (_capInsetsInternal.origin.x - l + _capInsetsInternal.size.width),
                                            h - (_capInsetsInternal.origin.y - t + _capInsetsInternal.size.height))
                            rotated:rotated
                            ];
        [_scale9Image addChild:_bottomRight z:2 tag:pBottomRight];
    }
    
    [self setContentSize:rect.size];
    [self addChild:_scale9Image];
    
    if (_spritesGenerated)
    {
        // Restore color and opacity
        self.opacity = opacity;
        self.color = color;
    }
    _spritesGenerated = YES;
}

- (void) setSpriteFrame:(CCSpriteFrame*)spriteFrame
{
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture capacity:9];
    [self updateWithBatchNode:batchnode rect:spriteFrame.rect rotated:spriteFrame.rotated capInsets:CGRectZero];
    
    // Reset insets
    _insetLeft      = 0;
    _insetTop       = 0;
    _insetRight     = 0;
    _insetBottom    = 0;
}

- (CCRepeat9Sprite*) resizableSpriteWithCapInsets:(CGRect)capInsets
{
    return [[[CCRepeat9Sprite alloc] initWithBatchNode:_scale9Image rect:_spriteRect capInsets:_capInsets] autorelease];
}

#pragma mark CCRepeat9Sprite Create Methods
//+ (CCRepeat9Sprite*) create
//{
//}
//
//+ (CCRepeat9Sprite*) create:(NSString*)file rect:(CGRect)rect  capInsets:(CGRect)capInsets
//{
//}
//
//+ (CCRepeat9Sprite*) create:(CGRect)capInsets file:(NSString*)file
//{
//}
//
//+ (CCRepeat9Sprite*) create:(NSString*)file rect:(CGRect)rect
//{
//}
//
//+ (CCRepeat9Sprite*) create:(NSString*)file
//{
//}
//
//+ (CCRepeat9Sprite*) createWithSpriteFrame:(CCSpriteFrame*)spriteFrame
//{
//}
//
//+ (CCRepeat9Sprite*) createWithSpriteFrame:(CCSpriteFrame*)spriteFrame capInsets:(CGRect)capInsets
//{
//}
//
//+ (CCRepeat9Sprite*) createWithSpriteFrameName:(NSString*)spriteFrameName
//{
//}
//
//+ (CCRepeat9Sprite*) createWithSpriteFrameName:(NSString*)spriteFrameName capInsets:(CGRect)capInsets
//{
//}

#pragma mark CCRepeat9Sprite Init Methods
- (id) init
{
    return [self initWithBatchNode:NULL rect:CGRectZero capInsets:CGRectZero];
}

- (id) initWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    return [self initWithBatchNode:batchnode rect:rect rotated:NO capInsets:capInsets];
}

- (id) initWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect rotated:(bool)rotated capInsets:(CGRect)capInsets
{
    if ((self = [super init]))
    {
        if (batchnode)
        {
            [self updateWithBatchNode:batchnode rect:rect rotated:rotated capInsets:capInsets];
            _anchorPoint        = ccp(0.5f, 0.5f);
        }
        _positionsAreDirty = YES;
    }
    return self;
}

- (id) initWithFile:(NSString*)file rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithFile:file capacity:9];
    
    return [self initWithBatchNode:batchnode rect:rect capInsets:capInsets];
}

- (id) initWithFile:(NSString*)file rect:(CGRect)rect
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:rect capInsets:CGRectZero];
}

- (id)initWithFile:(NSString *)file capInsets:(CGRect)capInsets
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:CGRectZero capInsets:capInsets];
}

- (id) initWithFile:(NSString*) file
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:CGRectZero];
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame capInsets:(CGRect)capInsets
{
    NSAssert(spriteFrame != nil, @"Sprite frame must be not nil");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture capacity:9];
    
    return [self initWithBatchNode:batchnode rect:spriteFrame.rect rotated:spriteFrame.rotated capInsets:capInsets];
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
    NSAssert(spriteFrame != nil, @"Invalid spriteFrame for sprite");
    
    return [self initWithSpriteFrame:spriteFrame capInsets:CGRectZero];
}

- (id) initWithSpriteFrameName:(NSString*)spriteFrameName capInsets:(CGRect)capInsets
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
    
    return [self initWithSpriteFrame:frame capInsets:capInsets];
}

- (id) initWithSpriteFrameName:(NSString*)spriteFrameName
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    return [self initWithSpriteFrameName:spriteFrameName capInsets:CGRectZero];
}

- (id)valueForUndefinedKey:(NSString *)key
{
//    NSArray* chunks = [key componentsSeparatedByString:@"|"];
//    if ([chunks count] == 2)
//    {
//        NSString* keyChunk = [chunks objectAtIndex:0];
//        int state = [[chunks objectAtIndex:1] intValue];
//        
//        if ([keyChunk isEqualToString:@"title"])
//        {
//            return [self titleForState:state];
//        }
//        else if ([keyChunk isEqualToString:@"titleColor"])
//        {
//            ccColor3B c = [self titleColorForState:state];
//            return [NSValue value:&c withObjCType:@encode(ccColor3B)];
//        }
//        else if ([keyChunk isEqualToString:@"titleBMFont"])
//        {
//            return [self titleBMFontForState:state];
//        }
//        else if ([keyChunk isEqualToString:@"titleTTF"])
//        {
//            return [self titleTTFForState:state];
//        }
//        else if ([keyChunk isEqualToString:@"titleTTFSize"])
//        {
//            return [NSNumber numberWithFloat:[self titleTTFSizeForState:state]];
//        }
//        else
//        {
//            return [super valueForUndefinedKey:key];
//        }
//    }
//    else
//    {
//        return [super valueForUndefinedKey:key];
//    }
    NSLog(@"CCRepeat9Sprite valueForUndefinedKey: %@", key);
}

@end
