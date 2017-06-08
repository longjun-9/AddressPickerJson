//
//  ViewController.m
//  AddressPickerJson
//
//  Created by Longjun on 2017/6/8.
//  Copyright © 2017年 Longjun. All rights reserved.
//

#import "ViewController.h"
#import "ActionSheetCustomPicker.h"

#define UIColorFromHex(rgbValue)                                                                                       \
    [UIColor colorWithRed:((float) ((rgbValue & 0xFF0000) >> 16)) / 255.0f                                             \
                    green:((float) ((rgbValue & 0x00FF00) >> 8)) / 255.0f                                              \
                     blue:((float) (rgbValue & 0x0000FF)) / 255.0f                                                     \
                    alpha:1.0f]

@interface ViewController () <ActionSheetCustomPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *codeLbl;
@property (nonatomic, strong) NSArray *addressArr;  // 解析出来的最外层数组
@property (nonatomic, strong) NSArray *provinceArr; // 省
@property (nonatomic, strong) NSArray *cityArr;     // 市
@property (nonatomic, strong) NSArray *countryArr;  // 区
@property (nonatomic, assign) NSInteger index0;     // 省下标
@property (nonatomic, assign) NSInteger indexBak0;  // 省下标备份
@property (nonatomic, assign) NSInteger index1;     // 市下标
@property (nonatomic, assign) NSInteger indexBak1;  // 市下标备份
@property (nonatomic, assign) NSInteger index2;     // 区下标
@property (nonatomic, assign) NSInteger indexBak2;  // 区下标备份

@property (nonatomic, strong) ActionSheetCustomPicker *picker; // 选择器
@property (nonatomic, copy) NSString *regionCode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.indexBak0 = self.index0;
    self.indexBak1 = self.index1;
    self.indexBak2 = self.index2;
}

- (IBAction)btnClicked:(id)sender {
    [self calculateData];
    [self.picker showActionSheetPicker];
    UIPickerView *pickerView = (UIPickerView *) self.picker.pickerView;
    [pickerView selectRow:self.index0 inComponent:0 animated:NO];
    [pickerView selectRow:self.index1 inComponent:1 animated:NO];
    [pickerView selectRow:self.index2 inComponent:2 animated:NO];
}

- (ActionSheetCustomPicker *)picker {
    if (!_picker) {
        _picker = [[ActionSheetCustomPicker alloc] initWithTitle:@""
                                                        delegate:self
                                                showCancelButton:YES
                                                          origin:self.view
                                               initialSelections:nil];
        _picker.tapDismissAction = TapActionSuccess;
        // 可以自定义左边和右边的按钮
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelButton setTitleColor:UIColorFromHex(0x4a4a4a) forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(0, 0, 44, 44);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];

        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [doneButton setTitleColor:UIColorFromHex(0x4a4a4a) forState:UIControlStateNormal];
        doneButton.frame = CGRectMake(0, 0, 44, 44);
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [_picker setCancelButton:[[UIBarButtonItem alloc] initWithCustomView:cancelButton]];
        [_picker setDoneButton:[[UIBarButtonItem alloc] initWithCustomView:doneButton]];
    }
    return _picker;
}

- (void)calculateData {
    // 拿出省的数组
    // 注意JSON后缀的东西和Plist不同，Plist可以直接通过contentOfFile抓取，Json要先打成字符串，然后用工具转换
    NSString *path = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"json"];
    NSString *jsonStr = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
    self.addressArr = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                      options:kNilOptions
                                                        error:nil];

    NSMutableArray *provinceNameArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.addressArr) {
        NSString *name = dict[@"name"];
        [provinceNameArr addObject:name];
    }
    // 第一层是省份 分解出整个省份数组
    self.provinceArr = provinceNameArr;

    NSMutableArray *cityArr = [[NSMutableArray alloc] init];
    // 根据省的index0，默认是0，拿出对应省下面的市
    NSArray *selectedCityArr = self.addressArr[self.index0][@"cities"];
    for (NSDictionary *city in selectedCityArr) {
        [cityArr addObject:city];
    }
    // 组装对应省下面的市
    self.cityArr = cityArr;

    NSArray *selectedCountryArr = selectedCityArr[self.index1][@"countries"];
    // 这里的allValue是取出来的大数组，取第0个就是需要的内容
    self.countryArr = selectedCountryArr;
}

#pragma mark - UIPickerViewDataSource Implementation
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    NSInteger num = 3;
    return num;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger rows = 0;
    switch (component) {
        case 0: {
            rows = self.provinceArr.count;
        } break;
        case 1: {
            rows = self.cityArr.count;
        } break;
        case 2: {
            rows = self.countryArr.count;
        } break;

        default:
            break;
    }

    return rows;
}

#pragma mark UIPickerViewDelegate Implementation

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 36;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    UILabel *label = (UILabel *) view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        [label setFont:[UIFont systemFontOfSize:14]];
        label.textAlignment = NSTextAlignmentCenter;
    }

    NSString *title = @"";
    switch (component) {
        case 0: {
            title = self.provinceArr[row];
        } break;
        case 1: {
            title = self.cityArr[row][@"name"];
        } break;
        case 2: {
            title = self.countryArr[row][@"name"];
        } break;

        default:
            break;
    }

    label.text = title;

    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            self.index0 = row;
            self.index1 = 0;
            self.index2 = 0;
            [self calculateData];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
        } break;

        case 1: {
            self.index1 = row;
            self.index2 = 0;
            [self calculateData];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:2];
        } break;
        case 2: {
            self.index2 = row;
        } break;

        default:
            break;
    }
}

- (void)actionSheetPicker:(AbstractActionSheetPicker *)actionSheetPicker
      configurePickerView:(UIPickerView *)pickerView {
    pickerView.showsSelectionIndicator = NO;
}

- (void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    self.index0 = self.indexBak0;
    self.index1 = self.indexBak1;
    self.index2 = self.indexBak2;
}

// 点击done的时候回调
- (void)actionSheetPickerDidSucceed:(ActionSheetCustomPicker *)actionSheetPicker origin:(id)origin {
    self.indexBak0 = self.index0;
    self.indexBak1 = self.index1;
    self.indexBak2 = self.index2;

    NSMutableString *detailAddress = [[NSMutableString alloc] init];
    if (self.index0 < self.provinceArr.count) {
        NSString *firstAddress = self.provinceArr[self.index0];
        [detailAddress appendString:firstAddress];
    }
    if (self.index1 < self.cityArr.count) {
        NSString *secondAddress = self.cityArr[self.index1][@"name"];
        [detailAddress appendString:secondAddress];
    }
    if (self.index2 < self.countryArr.count) {
        NSString *thirdAddress = self.countryArr[self.index2][@"name"];
        [detailAddress appendString:thirdAddress];
    }
    // 此界面显示
    self.addressLbl.text = detailAddress;

    NSString *code = nil;
    if (self.countryArr.count == 0) {
        code = self.cityArr[self.index1][@"code"];
    } else {
        code = self.countryArr[self.index2][@"code"];
    }
    self.regionCode = code;
    self.codeLbl.text = code;
}

- (NSArray *)provinceArr {
    if (_provinceArr == nil) {
        _provinceArr = [[NSArray alloc] init];
    }
    return _provinceArr;
}
- (NSArray *)cityArr {
    if (_cityArr == nil) {
        _cityArr = [[NSArray alloc] init];
    }
    return _cityArr;
}

- (NSArray *)countryArr {
    if (_countryArr == nil) {
        _countryArr = [[NSArray alloc] init];
    }
    return _countryArr;
}

-(NSArray *)addressArr
{
    if (_addressArr == nil) {
        _addressArr = [[NSArray alloc] init];
    }
    return _addressArr;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
