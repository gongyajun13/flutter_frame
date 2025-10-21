# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
 -keep class com.bytedance.sdk.openadsdk.** { *; }
 -keep public interface com.bytedance.sdk.openadsdk.downloadnew.** {*;}
 -keep class com.pgl.sys.ces.* {*;}

 -dontwarn com.tencent.bugly.**
 -keep public class com.tencent.bugly.**{*;}


-keep class time.master.aiera.com.bean.**{*;}

-keep class com.tencent.stat.*{*;}

-keep class com.tencent.mid.*{*;}


-keepclasseswithmembernames class ** {
    native <methods>;
}
-keepattributes Signature
-keep class aiera.sneaker.snkrs.aiera.aliyun.*{*;}
-keep class com.taobao.** {*;}
-keep class com.alibaba.** {*;}
-keep class com.alipay.** {*;}
-keep class com.ut.** {*;}
-keep class com.ta.** {*;}
-keep class anet.**{*;}
-keep class anetwork.**{*;}
-keep class org.android.spdy.**{*;}
-keep class org.android.agoo.**{*;}
-keep class android.os.**{*;}
-dontwarn com.taobao.**
-dontwarn com.alibaba.**
-dontwarn com.alipay.**
-dontwarn anet.**
-dontwarn org.android.spdy.**
-dontwarn org.android.agoo.**
-dontwarn anetwork.**
-dontwarn com.ut.**
-dontwarn com.ta.**
#通道
-keep class com.alibaba.sdk.** {*;}
-keep class com.alibaba.sdk.android.push.*{*;}
# 小米通道
-keep class com.xiaomi.** {*;}
-dontwarn com.xiaomi.**
# 华为通道
-keep class com.huawei.** {*;}
-dontwarn com.huawei.**
# GCM/FCM通道
-keep class com.google.firebase.**{*;}
-dontwarn com.google.firebase.**
# OPPO通道
-keep public class * extends android.app.Service
# VIVO通道
-keep class com.vivo.** {*;}
-dontwarn com.vivo.**
# 魅族通道
-keep class com.meizu.cloud.** {*;}
-dontwarn com.meizu.cloud.**

-dontwarn com.tencent.mm.**

-keep class com.tencent.**{*;}


# glide 的混淆代码
-keep public class * implements com.bumptech.glide.module.GlideModule
-keep public enum com.bumptech.glide.load.resource.bitmap.ImageHeaderParser$** {
  **[] $VALUES;
  public *;
}
# banner 的混淆代码
-keep class com.youth.banner.** {
    *;
 }

-dontwarn com.tencent.bugly.**
-keep public class com.tencent.bugly.**{*;}


# 保护内部类
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

-keep class com.bytedance.sdk.openadsdk.** { *; }
-keep public interface com.bytedance.sdk.openadsdk.downloadnew.** {*;}
-keep class com.pgl.sys.ces.* {*;}


-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}


-keep class com.alivc.**{*;}
-keep class com.aliyun.**{*;}
-dontwarn com.alivc.**
-dontwarn com.aliyun.**

#PictureSelector 2.0
-keep class com.luck.picture.lib.** { *; }

#Ucrop
-dontwarn com.yalantis.ucrop**
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }

#Okio
-dontwarn org.codehaus.mojo.animal_sniffer.*

#sina weibo sdk
-keep public class com.sina.weibo.sdk.**{*;}

# 云信
-dontwarn com.netease.**
-keep class com.netease.** { *; }
#如果你使用全文检索插件，需要加入
-dontwarn org.apache.lucene.**
-keep class org.apache.lucene.** {*;}

-keepclassmembers class ** {
    public void onEvent*(**);
    void onEvent*(**);
}

#如果你开启数据库功能，需要加入
-keep class net.sqlcipher.** {*;}
-keep class org.json.** {*;}

-keep class com.umeng.** {*;}

-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keep public class aiera.sneaker.snkrs.aiera.R$*{
public static final int *;
}

# ok Http3
-dontwarn com.squareup.okhttp3.**
-keep class com.squareup.okhttp3.** { *;}
-dontwarn okio.**

#
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

-keepattributes *Annotation*


-keep public class * extends android.view.View{
    *** get*();
    void set*(***);
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}


#PictureSelector 2.0
-keep class com.luck.picture.lib.** { *; }

#Ucrop
-dontwarn com.yalantis.ucrop**
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }

-keep class **.R${
 *;
}
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keep class com.baidu.mobads.** { *; }
-keep class com.baidu.mobad.** { *; }
-keep class com.bun.** {*;}

-keep class org.chromium.** {*;}
-keep class org.chromium.** { *; }
-keep class aegon.chrome.** { *; }
-keep class com.baidu.mobstat.** { *; }


-keep class com.bun.** { *;}
-keep class com.netease.nis.** {*;}
#快手
-keep class org.chromium.** {*;}
-keep class org.chromium.** { *; }
-keep class aegon.chrome.** { *; }
-keep class com.kwad.sdk.** { *;}
-keep class com.ksad.download.** { *;}
-keep class com.kwai.**{ *; }
-keep class com.yxcorp.kuaishou.addfp.** {*;}
-dontwarn com.kwai.**
-dontwarn com.kwad.**
-dontwarn com.ksad.**
-dontwarn aegon.chrome.**
#快手


# sdk
-keep class com.bun.** { *; }
# asus
-keep class com.asus.msa.SupplementaryDID.** { *; } -keep class com.asus.msa.sdid.** { *; }
# freeme
-keep class com.android.creator.** { *; }
-keep class com.android.msasdk.** { *; }
# huawei
-keep class com.huawei.hms.ads.identifier.** { *; } #-keep class com.uodis.opendevice.aidl.** { *; }
# lenovo
-keep class com.zui.deviceidservice.** { *; }
-keep class com.zui.opendeviceidlibrary.** { *; }
# meizu
-keep class com.meizu.flyme.openidsdk.** { *; }

# oppo
-keep class com.heytap.openid.** { *; }
# samsung
-keep class com.samsung.android.deviceidservice.** { *; }
# vivo
-keep class com.vivo.identifier.** { *; }

# zte
-keep class com.bun.lib.** { *; }
# coolpad
-keep class com.coolpad.deviceidsupport.** { *; }


-keep class com.alivc.**{*;}
-keep class com.aliyun.**{*;}
-keep class com.cicada.**{*;}
-dontwarn com.alivc.**
-dontwarn com.aliyun.**
-dontwarn com.cicada.**


-dontwarn com.qiyukf.**
-keep class com.qiyukf.** {*;}
-dontwarn com.netease.**
-keep class com.netease.** {*;}
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

## pangle 穿山甲原有的
-keepclassmembers class * {
    *** getContext(...);
    *** getActivity(...);
    *** getResources(...);
    *** startActivity(...);
    *** startActivityForResult(...);
    *** registerReceiver(...);
    *** unregisterReceiver(...);
    *** query(...);
    *** getType(...);
    *** insert(...);
    *** delete(...);
    *** update(...);
    *** call(...);
    *** setResult(...);
    *** startService(...);
    *** stopService(...);
    *** bindService(...);
    *** unbindService(...);
    *** requestPermissions(...);
    *** getIdentifier(...);
   }

-keep class com.bytedance.pangle.** {*;}
-keep class com.bytedance.sdk.openadsdk.** { *; }
-keep class com.bytedance.frameworks.** { *; }

-keep class ms.bd.c.Pgl.**{*;}
-keep class com.bytedance.mobsec.metasec.ml.**{*;}

-keep class com.ss.android.**{*;}

-keep class com.bytedance.embedapplog.** {*;}
-keep class com.bytedance.embed_dr.** {*;}

-keep class com.bykv.vk.** {*;}


#聚合混淆
-keep class bykvm*.**
-keep class com.bytedance.msdk.adapter.**{ public *; }
-keep class com.bytedance.msdk.api.** {
 public *;
}
-keep class com.bytedance.msdk.base.TTBaseAd{*;}
-keep class com.bytedance.msdk.adapter.TTAbsAdLoaderAdapter{
    public *;
    protected <fields>;
}
#===ks_start===
#ks 快手 不接入ks sdk可以不引入
-keep class org.chromium.** {*;}
-keep class org.chromium.** { *; }
-keep class aegon.chrome.** { *; }
-keep class com.kwai.**{ *; }
-dontwarn com.kwai.**
-dontwarn com.kwad.**
-dontwarn com.ksad.**
-dontwarn aegon.chrome.**
#===ks_end===

-keep class com.kwai.**{ *; }
-keep class com.kwad.sdk.** { *;}
-keep class com.ksad.download.** { *;}
-keep class com.yxcorp.kuaishou.addfp.** {*;}


-keep class org.chromium.** {*;}
-keep class org.chromium.** { *; }
-keep class aegon.chrome.** { *; }
-keep class com.baidu.mobstat.** { *; }

-keep class com.bun.miitmdid.** { *;}
-keep class com.netease.nis.** {*;}

-keep class com.aiear.basepack.model.** { * ;}
-keep class com.aiera.http.model.** { * ;}
-keep class com.aiera.http.func.** { * ;}

# OkHttp3 规则
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# OkHttp 内部类规则
-keepclasseswithmembers class okhttp3.internal.** {
    *;
}

# UCrop 规则
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
