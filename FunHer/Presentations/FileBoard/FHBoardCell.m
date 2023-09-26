//
//  FHBoardCell.m
//  FunHer
//
//  Created by GLA on 2023/9/14.
//

#import "FHBoardCell.h"
#import "FHBoardCellModel.h"

@interface FHBoardCell ()
@property (nonatomic, strong) UIView  *bgView;
@property (nonatomic, strong) UIImageView  *imgV;
@property (nonatomic, strong) UILabel      *titleLabel;
@property (nonatomic, strong) UILabel      *numLabel;

@end

@implementation FHBoardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configContentView];
    }
    return self;
}


- (void)configCellWithData:(FHBoardCellModel *)fileTargetModel  {
    self.titleLabel.text = fileTargetModel.fileName;
    self.numLabel.text = fileTargetModel.countNum;
}

- (void)configContentView {
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.imgV];
    UIStackView *stack = [self labStack];
    [self.bgView addSubview:stack];
    [stack addArrangedSubview:self.titleLabel];
    [stack addArrangedSubview:self.numLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bgView).offset(15);
        make.centerY.equalTo(self.bgView);
    }];
    
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.imgV.mas_trailing).offset(15);
        make.centerY.equalTo(self.imgV.mas_centerY).offset(0);
    }];
}

#pragma mark -- lazy
- (UIStackView *)labStack {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.distribution = UIStackViewDistributionFill;;
    stackView.spacing = 5;
    return stackView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = kWhiteColor;
    }
    return _bgView;
}

- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
        _imgV.image = [UIImage imageNamed:@"new_folder"];
        _imgV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgV;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kTextBlackColor;
        _titleLabel.font = PingFang_R_FONT_(16);
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentNatural;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _titleLabel;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = kTextGrayColor;
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.font = PingFang_R_FONT_(13);
    }
    return _numLabel;
}




- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
