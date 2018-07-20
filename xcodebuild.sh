#author by 得力
#计时
SECONDS=0

#注意：脚本目录和WorkSpace目录在同一个目录

apppath=$(cd `dirname $0`; pwd)
echo "~~~~~~~~~~~~请确认当前目录是否为App目录 $apppath~~~~~~~~~~~"

sleep 1.5

#工程名字(Target名字)
Project_Name="jinshanStrmear"
#workspace的名字
Workspace_Name="jinshanStrmear"
#配置环境，Release或者Debug,默认release
Configuration="Release"
#指定输出ipa地址
ipa_path="$apppath/AppBuild"
#指定上传fir的apiToken
firToken="53651903eb5fa8cc21c798074b2bf2db"
#AdHoc版本的Bundle ID
AdHocBundleID="com.yiju.joustar"
#AppStore版本的Bundle ID
AppStoreBundleID="com.yiju.joustar"
#enterprise的Bundle ID
EnterpriseBundleID="com.yiju.joustar"

# ADHOC证书名#描述文件
ADHOCCODE_SIGN_IDENTITY="iPhone Developer: Guoqing zhou"
ADHOCPROVISIONING_PROFILE_NAME="allStarDevelopment"

#AppStore证书名#描述文件
APPSTORECODE_SIGN_IDENTITY="iPhone Distribution: bei jing yi ju chuang yi technology Co.,Ltd."
APPSTOREROVISIONING_PROFILE_NAME="AllStarDistribution"

#企业(enterprise)证书名#描述文件
ENTERPRISECODE_SIGN_IDENTITY="iPhone Distribution: xxxx"
ENTERPRISEROVISIONING_PROFILE_NAME="xxxxx-xxxx-xxx-xxxx"

#加载各个版本的plist文件
ADHOCExportOptionsPlist=./ADHOCExportOptionsPlist.plist
AppStoreExportOptionsPlist=./AppStoreExportOptionsPlist.plist
EnterpriseExportOptionsPlist=./EnterpriseExportOptionsPlist.plist

ADHOCExportOptionsPlist=${ADHOCExportOptionsPlist}
AppStoreExportOptionsPlist=${AppStoreExportOptionsPlist}
EnterpriseExportOptionsPlist=${EnterpriseExportOptionsPlist}

echo "~~~~~~~~~~~~选择打包方式(输入序号)~~~~~~~~~~~~~~~"
echo "		1 adHoc测试包"
echo "		2 AppStore正式包"
echo "		3 Enterprise"

# 读取用户输入并存到变量里
read parameter
sleep 0.5
method="$parameter"

# 判读用户是否有输入
if [ -n "$method" ]
then
if [ "$method" = "1" ]
then
#adhoc脚本
#如果需要测试证书则在build后添加因为xcode8自动管理证书设置了Automatically manage siging就可以了  CODE_SIGN_IDENTITY="${ADHOCCODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${ADHOCPROVISIONING_PROFILE_NAME}"
xcodebuild -workspace $Workspace_Name.xcworkspace -scheme $Project_Name -configuration $Configuration -archivePath $ipa_path/$Project_Name-adhoc.xcarchive clean archive build CODE_SIGN_IDENTITY="${ADHOCCODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${ADHOCPROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${AdHocBundleID}"
xcodebuild  -exportArchive -archivePath $ipa_path/$Project_Name-adhoc.xcarchive -exportOptionsPlist ${ADHOCExportOptionsPlist} -exportPath $ipa_path/$Project_Name-adhoc.ipa

elif [ "$method" = "2" ]
then
#appstore脚本
xcodebuild -workspace $Workspace_Name.xcworkspace -scheme $Project_Name -configuration $Configuration -archivePath $ipa_path/$Project_Name-appstore.xcarchive archive build CODE_SIGN_IDENTITY="${APPSTORECODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${APPSTOREROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${AppStoreBundleID}"
xcodebuild  -exportArchive -archivePath $ipa_path/$Project_Name-appstore.xcarchive -exportOptionsPlist ${AppStoreExportOptionsPlist} -exportPath $ipa_path/$Project_Name-appstore.ipa

elif [ "$method" = "3" ]
then
#企业打包脚本
xcodebuild -workspace $Workspace_Name.xcworkspace -scheme $Project_Name -configuration $Configuration -archivePath $ipa_path/$Project_Name-enterprise.xcarchive archive build CODE_SIGN_IDENTITY="${ENTERPRISECODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${ENTERPRISEROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${EnterpriseBundleID}"
xcodebuild  -exportArchive -archivePath $ipa_path/$Project_Name-enterprise.xcarchive -exportOptionsPlist ${EnterpriseExportOptionsPlist} -exportPath $ipa_path/$Project_Name-enterprise.ipa
else
echo "参数无效...."
exit 1
fi
fi

#上传到fir

fir publish $ipa_path/$Project_Name.ipa -T "${firToken}" -c "${commit_msg}"

echo " app的路径 $ipa_path/$Project_Name.ipa"


#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="
