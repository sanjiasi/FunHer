//
//  FHFileCollectionCell.m
//  FunHer
//
//  Created by GLA on 2023/7/31.
//

#import "FHFileCollectionCell.h"

@implementation FHFileCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configContentView];
    }
    return self;
}


#pragma mark -- private methods
- (void)configContentView {
    [self.contentView addSubview:self.showImg];
    [self.contentView addSubview:self.titleLab];
    
    [self.showImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.contentView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentView);
        make.top.equalTo(self.showImg.mas_bottom).offset(0);
        make.height.mas_equalTo(25);
    }];
}

#pragma mark -- getter and setters
- (UIImageView *)showImg {
    if (!_showImg) {
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"collectionicon"];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        _showImg = imgV;
    }
    return _showImg;
}

- (UILabel *)titleLab {
    if (_titleLab) {
        UILabel *lab = [[UILabel alloc] init];
        lab.textColor = RGBA(153, 153, 153, 1.0);
        lab.textAlignment = NSTextAlignmentNatural;
        lab.font = PingFang_R_FONT_(10);
        lab.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLab = lab;
    }
    return _titleLab;
}

@end
