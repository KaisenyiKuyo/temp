#include <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <vector>
#include <string>
#include "il2cpp.h"
#include "imgui.h"

bool unlockskin = false;
bool unlocknut = false;
bool modnotify = false;
int TypeKill = 0;
int idtype = 11107;

// Character data
std::string characterNames[] = {
    "Violet Thứ nguyên vệ Thần",
    "Violet Thần long tỷ tỷ",
    "Butterfly Kim ngư thần nữ",
    "Butterfly Thánh nữ khởi nguyên",
    "Krixi Phù thủy thời không",
    "Airi Thứ nguyên vệ thần",
    "Murad Tuyệt thế thần binh",
    "Lauriel Thứ nguyên vệ Thần",
    "Nakroth Kilua",
    "Nakroth Quỷ thương liệp đế",
    "Nakroth Bạch diện chiến thương",
    "Điêu thuyền Eternal Sailor Moon",
    "Yena Huyền cửu thiên",
    "Raz Gon",
    "Tulen gojo",
    "Enzo Kurapika",
    "Eland'orr Tuxedo mask",
    "Liliana Ma pháp tối thượng",
    "Veres Lưu ly long mẫu",
    "Aya Công chúa cầu vồng",
    "Biron Itadori",
    "Alice Eternal Sailor Moon",
    "Ilumia Lưỡng mi long hậu"
};

int characterIds[] = {
    11107, 11115, 11614, 11616, 10620,
    13015, 13116, 14111, 15012, 15013,
    15015, 15212, 15412, 15711, 19015,
    19508, 19906, 51015, 52011, 54307,
    59702, 11812, 13610
};

int selectedCharacterIndex = 0;

// CSProtocol namespace
namespace CSProtocol {
    class COMDT_HERO_COMMON_INFO {
    public:
        uint32_t getdwHeroID() {
            if (this == nullptr) return 0;
            return *(uint32_t *)((uint64_t)this + Field_AovTdr_dll_CSProtocol_COMDT_HERO_COMMON_INFO_dwHeroID);
        }
        
        uint16_t getwSkinID() {
            if (this == nullptr) return 0;
            return *(uint16_t *)((uint64_t)this + Field_AovTdr_dll_CSProtocol_COMDT_HERO_COMMON_INFO_wSkinID);
        }
        
        void setdwHeroID(uint32_t dwHeroID) {
            if (this == nullptr) return;
            *(uint32_t *)((uint64_t)this + Field_AovTdr_dll_CSProtocol_COMDT_HERO_COMMON_INFO_dwHeroID) = dwHeroID;
        }
        
        void setwSkinID(uint16_t wSkinID) {
            if (this == nullptr) return;
            *(uint16_t *)((uint64_t)this + Field_AovTdr_dll_CSProtocol_COMDT_HERO_COMMON_INFO_wSkinID) = wSkinID;
        }
    };
    
    struct saveData {
        static uint32_t heroId;
        static uint16_t skinId;
        static bool enable;
        static std::vector<std::pair<COMDT_HERO_COMMON_INFO*, uint16_t>> arrayUnpackSkin;
        
        static void setData(uint32_t hId, uint16_t sId) {
            heroId = hId;
            skinId = sId;
        }
        
        static void setEnable(bool eb) {
            enable = eb;
        }
        
        static void resetArrayUnpackSkin() {
            if (!arrayUnpackSkin.empty()) {
                for (const auto& skinInfo : arrayUnpackSkin) {
                    skinInfo.first->setwSkinID(skinInfo.second);
                }
                arrayUnpackSkin.clear();
            }
        }
    };
    
    uint32_t saveData::heroId = 0;
    uint16_t saveData::skinId = 0;
    bool saveData::enable = false;
    std::vector<std::pair<COMDT_HERO_COMMON_INFO*, uint16_t>> saveData::arrayUnpackSkin;
}

// Hook functions
void hook_unpack(CSProtocol::COMDT_HERO_COMMON_INFO* instance) {
    if (!CSProtocol::saveData::enable) return;
    if (instance->getdwHeroID() == CSProtocol::saveData::heroId && 
        CSProtocol::saveData::heroId != 0 && 
        CSProtocol::saveData::skinId != 0) {
        CSProtocol::saveData::arrayUnpackSkin.emplace_back(instance, instance->getwSkinID());
        instance->setwSkinID(CSProtocol::saveData::skinId);
    }
}

TdrErrorType (*old_unpack)(CSProtocol::COMDT_HERO_COMMON_INFO* instance, TdrReadBuf& srcBuf, int32_t cutVer);
TdrErrorType unpack(CSProtocol::COMDT_HERO_COMMON_INFO* instance, TdrReadBuf& srcBuf, int32_t cutVer) {
    TdrErrorType result = old_unpack(instance, srcBuf, cutVer);
    if (unlockskin) {
        hook_unpack(instance);
    }
    return result;
}

void (*old_RefreshHeroPanel)(void* instance, bool bForceRefreshAddSkillPanel, bool bRefreshSymbol, bool bRefreshHeroSkill);
void (*old_OnClickSelectHeroSkin)(void *instance, uint32_t heroId, uint32_t skinId);
void OnClickSelectHeroSkin(void *instance, uint32_t heroId, uint32_t skinId) {
    if (unlockskin && heroId != 0) {
        old_RefreshHeroPanel(instance, 1, 1, 1);
    }
    old_OnClickSelectHeroSkin(instance, heroId, skinId);
}

bool (*old_IsCanUseSkin)(void *instance, uint32_t heroId, uint32_t skinId);
bool IsCanUseSkin(void *instance, uint32_t heroId, uint32_t skinId) {
    if (unlockskin) {
        if (heroId != 0) {
            CSProtocol::saveData::setData(heroId, skinId);
        }
        return 1;
    }
    return old_IsCanUseSkin(instance, heroId, skinId);
}

uint32_t (*old_GetHeroWearSkinId)(void* instance, uint32_t heroId);
uint32_t GetHeroWearSkinId(void* instance, uint32_t heroId) {
    if (unlockskin) {
        CSProtocol::saveData::setEnable(true);
        return CSProtocol::saveData::skinId;
    }
    return old_GetHeroWearSkinId(instance, heroId);
}

bool (*old_IsHaveHeroSkin)(uintptr_t heroId, uintptr_t skinId, bool isIncludeTimeLimited);
bool IsHaveHeroSkin(uintptr_t heroId, uintptr_t skinId, bool isIncludeTimeLimited = false) {
    if (unlockskin) {
        return 1;
    }
    return old_IsHaveHeroSkin(heroId, skinId, isIncludeTimeLimited);
}

bool (*_IsOpen)(void* instance);
bool IsOpen(void* instance) {
    if (unlocknut) {
        return true;
    }
    return _IsOpen(instance);
}

int (*_Get_PersonalBtnId)(void* instance);
int Get_PersonalBtnId(void* instance) {
    if (instance != NULL && unlocknut) {
        return idtype;
    }
    return _Get_PersonalBtnId(instance);
}

List<void *> *(*PlrList)(void *ins);
void (*_Getuid)(void *ins, int uid);
void Getuid(void *ins, int uid) {
    if (ins != NULL && TypeKill != 0 && modnotify) {
        List<void *> *target = PlrList(ins);
        if (target != NULL) {
            void **playerItem = (void **)target->getItems();
            for (int i = 0; i < target->getSize(); i++) {
                void *Player = playerItem[i];
                if (Player != NULL) {
                    *(int *)((uintptr_t)Player + GetFieldOffset("Project.Plugins_d.dll", "LDataProvider", "PlayerBase", "broadcastID")) = TypeKill;
                }
            }
        }
    }
    return _Getuid(ins, uid);
}

void buttonSelect() {
    if (ImGui::BeginCombo("choose button", characterNames[selectedCharacterIndex].c_str())) {
        for (int i = 0; i < sizeof(characterIds)/sizeof(characterIds[0]); i++) {
            bool isSelected = (i == selectedCharacterIndex);
            if (ImGui::Selectable(characterNames[i].c_str(), isSelected)) {
                selectedCharacterIndex = i;
                idtype = characterIds[i];     
            }
            if (isSelected) {
                ImGui::SetItemDefaultFocus();
            }
        }
        ImGui::EndCombo();
    }
}

void DrawModNotify() {
    static const char* options2[] = { 
        "Triệu Vân Thần Tài", 
        "Hayate Tu Di Thánh Đế", 
        "Ngộ Không Tân Niên Võ Thần", 
        "Điêu Thuyền Eternal Sailor Moon", 
        "Alice Eternal Sailor Chibi Moon", 
        "Eland'orr Tuxedo", 
        "Butterfly Thánh Nữ Khởi Nguyên", 
        "Enzo Kurapika", 
        "Nakroth Killua", 
        "Raz Gon", 
        "Yena Huyền Cửu Thiên", 
        "Airi Thứ Nguyên Vệ Thần", 
        "Murad Tuyệt Thế Thần Binh", 
        "Grakk Thần Ẩm Thực", 
        "Veres Lưu Ly Long Mẫu", 
        "Nakroth Quỷ Thương Liệp Đế", 
        "Aya Công Chúa Cầu Vồng", 
        "Nakroth Producer Tia Chớp", 
        "Krixi Phù Thuỷ Thời Không", 
        "Nakroth Bạch Diện Chiến Thương", 
        "Veera Phù Thủy Hội Họa", 
        "Liliana Ma Pháp Tối Thượng", 
        "Biron Yuji Itadori", 
        "Tulen Satoru Gojo", 
        "Ilumia Lưỡng Nghi Long Hậu", 
        "Violet Thứ Nguyên Vệ Thần", 
        "Capheny Càn Nguyên Điện Chủ", 
        "Allain Lân Sư Vũ Thần"
    };

    static int selectedValue2 = 0;
    ImGui::Combo("choose killfeed", &selectedValue2, options2, IM_ARRAYSIZE(options2));

    static const int typeKillMap[] = {
        1, 2, 3, 4, 5, 6, 7, 8, 9,
        10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
        20, 22, 23, 24, 25, 26, 28, 29, 30
    };

    if (selectedValue2 >= 0 && selectedValue2 < IM_ARRAYSIZE(typeKillMap)) {
        TypeKill = typeKillMap[selectedValue2];
    }
}

// Hook initialization
#define Hack(x, y, z) \
{ \
    NSString* result_##y = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), x, nullptr); \
    if (result_##y) { \
        void* result = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), x, (void *) y); \
        *(void **) (&z) = (void*) result; \
    } \
}

void InitializeHooks() {
    dispatch_once(&onceToken, ^{
        uint64_t unltb = Il2CppMethod("Project.Plugins_d.dll").getClass("NucleusDrive.Logic.GameKernal", "GamePlayerCenter").getMethod("GetPlayer", 1);
        
        OnClickSelectHeroSkinOffset = methodAccessSystem.getClass("Assets.Scripts.GameSystem", "HeroSelectNormalWindow").getMethod("OnClickSelectHeroSkin", 2);
        IsCanUseSkinOffset = methodAccessSystem.getClass("Assets.Scripts.GameSystem", "CRoleInfo").getMethod("IsCanUseSkin", 2);
        GetHeroWearSkinIdOffset = methodAccessSystem.getClass("Assets.Scripts.GameSystem", "CRoleInfo").getMethod("GetHeroWearSkinId", 1);
        IsHaveHeroSkinOffset = methodAccessSystem.getClass("Assets.Scripts.GameSystem", "CRoleInfo").getMethod("IsHaveHeroSkin", 3);
        unpackOffset = methodAccessRes.getClass("CSProtocol", "COMDT_HERO_COMMON_INFO").getMethod("unpack", 2);

        Hack(unpackOffset, unpack, old_unpack);
        Hack(OnClickSelectHeroSkinOffset, OnClickSelectHeroSkin, old_OnClickSelectHeroSkin);
        Hack(IsCanUseSkinOffset, IsCanUseSkin, old_IsCanUseSkin);
        Hack(GetHeroWearSkinIdOffset, GetHeroWearSkinId, old_GetHeroWearSkinId);
        Hack(IsHaveHeroSkinOffset, IsHaveHeroSkin, old_IsHaveHeroSkin);
        Hack(unltb, Getuid, _Getuid);
        Hack(Il2CppMethod("Project_d.dll").getClass("Assets.Scripts.GameSystem", "PersonalButton").getMethod("IsOpen", 0), IsOpen, _IsOpen);
        Hack(Il2CppMethod("Project_d.dll").getClass("Assets.Scripts.GameSystem", "PersonalButton").getMethod("get_PersonalBtnId", 0), Get_PersonalBtnId, _Get_PersonalBtnId);
    });
}

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@end

@implementation ImGuiDrawView

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    
    if (!self.device) abort();
    
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    
    ImGui_ImplMetal_Init(_device);
    
    return self;
}

- (void)drawInMTKView:(MTKView*)view {
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    
    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 120);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui"];
        
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        // Draw your ImGui UI here
        if (MenDeal) {
            ImGui::Begin("Menu", &MenDeal);
            
            // Unlock skin section
            ImGui::Checkbox("Unlock Skin", &unlockskin);
            
            // Unlock joystick section
            ImGui::Checkbox("Unlock Joystick", &unlocknut);
            if (unlocknut) {
                buttonSelect();
            }
            
            // Mod killfeed section
            ImGui::Checkbox("Mod Killfeed", &modnotify);
            if (modnotify) {
                DrawModNotify();
            }
            
            ImGui::End();
        }
        
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    
    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

@end