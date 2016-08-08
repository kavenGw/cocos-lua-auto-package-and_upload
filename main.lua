--内网热更新
print("----热更新开始")
local net = arg[1];

if net == "n" then
    Neiwang = true
elseif net == "w" then
    Neiwang = false
else
    print("未指定内外网 n 内网 w 外网")
    return
end

--配置表定义好 NeiwangIp NeiwangPass WaiwangIp WaiwangPass
require("config")

if Neiwang then
    Ip = NeiwangIp
    print("当前内网")
else
    Ip = WaiwangIp
    print("当前外网")
end
os.execute("sleep 3")

local needApk = arg[2];
if needApk == "apk" then
    generateAPK = true
else
    generateAPK = false
end

require("fileTool")
require("md5Tool")
require("ManifestTool")
require("StringBuffer")

print("-----删除luagame下impact 和 lang")
os.execute("rm -rf " .. "/Users/wucan/Desktop/BONS/cocos/root/LuaGame/res/lang")

print("-----拷贝BONSX res impact lang 到 luagame res")
copy("/Users/wucan/Desktop/BONS/cocos/root/BONSX/res/lang","/Users/wucan/Desktop/BONS/cocos/root/LuaGame/res")

print("-----删除BONSX/res")
deleteDir("/Users/wucan/Desktop/BONS/cocos/root/BONSX/res")

print("-----拷贝luagame res 到 BONSX res")
copy("/Users/wucan/Desktop/BONS/cocos/root/LuaGame/res","/Users/wucan/Desktop/BONS/cocos/root/BONSX")


print("删除 临时目录 input 和 output ")
local inputDir = "inPut"
local outPutDir = "outPut"
deleteDir(outPutDir)
deleteDir(inputDir)

print("从BONSX拷贝新的代码和资源到临时目录")
local sourceFileNames = {
    "src","res"
}
local sourceSrc = "/Users/wucan/Desktop/BONS/cocos/root/BONSX/"
for index,sourceFileName in ipairs(sourceFileNames) do
    local path = sourceSrc .. sourceFileName
    copy(path,inputDir)
end

print("将资源从input拷贝到output")
copy(inputDir.."/src",outPutDir.."/src")
copy(inputDir.."/res",outPutDir.."/res")

if Neiwang then
    print("生成output manifest")
    generateManifest("output")

    print("拷贝mainfest到src")
    copy(outPutDir .. "/project.manifest",outPutDir.."/src/project.manifest")
    print("拷贝mainfest到BONSX/src")
    copy(outPutDir .. "/project.manifest",sourceSrc.."/src/project.manifest")

    print("删除serverlist")
    deleteFile("output/src/serverList.lua")
    copy("serverList_nei.lua","output/src/serverList.lua")
else
    print("开始刷新外网资源")
    deleteDir("outputWai")
    os.execute("sleep " .. 1)

    print("编译lua文件")
    os.execute("cocos luacompile -s output/src -d outputWai/src -e -k fqwcxzv1f232dsafz -b fewqvcxzfqadfvxz --disable-compile")
    print("删除main.luac")
    os.execute("rm -rf " .. "outputWai/src/main.luac")
    print("拷贝main.lua")
    copy("output/src/main.lua","outputWai/src/main.lua")
    print("拷贝res")
    copy("output/res","outputWai/res")

    print("等待5秒")
    os.execute("sleep " .. 5)

    print("生成outputWai manifest")
    generateManifest("outputWai")

    print("拷贝mainfest到src")
    copy("outputWai/project.manifest","outputWai/src/project.manifest")


    print("删除serverlist")
    deleteFile("outputWai/src/serverList.luac")
    copy("serverList_wai.lua","outputWai/src/serverList.lua")

    print("删除 android studio assets目录")
    print("拷贝到Android studio assets目录")
    deleteDir("/Users/wucan/Desktop/BONS/cocos/root/BONSX/frameworks/runtime-src/proj.android-studio/app/assets/src")
    deleteDir("/Users/wucan/Desktop/BONS/cocos/root/BONSX/frameworks/runtime-src/proj.android-studio/app/assets/res")
    print("等待5秒")
    os.execute("sleep " .. 5)
    copy("outputWai/src","/Users/wucan/Desktop/BONS/cocos/root/BONSX/frameworks/runtime-src/proj.android-studio/app/assets")
    copy("outputWai/res","/Users/wucan/Desktop/BONS/cocos/root/BONSX/frameworks/runtime-src/proj.android-studio/app/assets")

end


print("完成 5 秒后开始上传服务器")
os.execute("sleep " .. 5)

--上传到服务器

local function uploadDile(src,srcd)
    print("上传" .. src)
    os.execute("scp -r " .. src .. " "..srcd)
end

print("开始上传文件")
if Neiwang then
    print("密码 " .. NeiwangPass)
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/output/res","root@10.0.81.200:/var/www/html/package")
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/output/src","root@10.0.81.200:/var/www/html/package")
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/output/project.manifest","root@10.0.81.200:/var/www/html")
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/output/version.manifest","root@10.0.81.200:/var/www/html")
else
    print("密码 " .. WaiwangPass)
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/outputWai/res","root@121.41.76.100:/var/www/html/package")
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/outputWai/src","root@121.41.76.100:/var/www/html/package")
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/outputWai/project.manifest","root@121.41.76.100:/var/www/html")
    uploadDile("/Users/wucan/Desktop/吴灿/项目新时代/cocos热更新工具/outputWai/version.manifest","root@121.41.76.100:/var/www/html")
end



print("完成 2 秒后开始生成apk")
os.execute("sleep " .. 2)

if Neiwang then
    if generateAPK then
        print("开始生成android安装包")
        os.execute("cocos compile -s /Users/wucan/Desktop/BONS/cocos/root/BONSX/ -p android -l 19")
        print("拷贝安装包")
        os.execute("mv /Users/wucan/Desktop/BONS/cocos/root/BONSX/simulator/android/BONSX-debug.apk /Users/wucan/Desktop/BONS/策划配置/root/版本安装包/北欧女神像内网.apk")
    end
else
    -- if generateAPK then
    --     print("开始生成android安装包")
    --     os.execute("/Users/wucan/Desktop/BONS/cocos/root/BONSX/frameworks/runtime-src/proj.android-studio/gradlew assembleRelease")
    --     print("拷贝安装包")
    --     os.execute("mv /Users/wucan/Desktop/BONS/cocos/root/BONSX/frameworks/runtime-src/proj.android-studio/app/build/outputs/apk/BONSX-release-unsigned.apk /Users/wucan/Desktop/BONS/策划配置/root/版本安装包/北欧女神像外网.apk")
    -- end
end