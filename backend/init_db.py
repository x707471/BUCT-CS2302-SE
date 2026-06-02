from datetime import date, datetime
from models import (
    db, Museum, Dynasty, Artist, Location, Artifact, ArtifactImage,
    Role, Permission, RolePermission, User, UserRole, ViolationType,
)


def init_db(app):
    with app.app_context():
        db.create_all()
        _seed_data(app)


def _seed_data(app):
    if Museum.query.first() is not None:
        return

    from werkzeug.security import generate_password_hash

    museums_data = [
        {"name": "中国国家博物馆", "short_name": "国博", "country": "中国", "city": "北京", "website": "http://www.chnmuseum.cn"},
        {"name": "故宫博物院", "short_name": "故宫", "country": "中国", "city": "北京", "website": "https://www.dpm.org.cn"},
        {"name": "湖北省博物馆", "short_name": "鄂博", "country": "中国", "city": "武汉", "website": "http://www.hbww.org"},
        {"name": "河北省博物院", "short_name": "冀博", "country": "中国", "city": "石家庄", "website": "http://www.hebeimuseum.org"},
        {"name": "甘肃省博物馆", "short_name": "甘博", "country": "中国", "city": "兰州", "website": "http://www.gansumuseum.com"},
        {"name": "台北故宫博物院", "short_name": "北院", "country": "中国", "city": "台北", "website": "https://www.npm.gov.tw"},
        {"name": "秦始皇帝陵博物院", "short_name": "秦陵", "country": "中国", "city": "西安", "website": "http://www.bmy.com.cn"},
    ]
    museums = []
    for data in museums_data:
        m = Museum(**data)
        db.session.add(m)
        museums.append(m)
    db.session.flush()

    dynasties_data = [
        {"name_zh": "商代", "name_en": "Shang Dynasty", "start_year": -1600, "end_year": -1046},
        {"name_zh": "西周", "name_en": "Western Zhou", "start_year": -1046, "end_year": -771},
        {"name_zh": "春秋", "name_en": "Spring and Autumn", "start_year": -770, "end_year": -476},
        {"name_zh": "战国", "name_en": "Warring States", "start_year": -475, "end_year": -221},
        {"name_zh": "秦代", "name_en": "Qin Dynasty", "start_year": -221, "end_year": -206},
        {"name_zh": "西汉", "name_en": "Western Han", "start_year": -206, "end_year": 25},
        {"name_zh": "东汉", "name_en": "Eastern Han", "start_year": 25, "end_year": 220},
        {"name_zh": "唐代", "name_en": "Tang Dynasty", "start_year": 618, "end_year": 907},
        {"name_zh": "北宋", "name_en": "Northern Song", "start_year": 960, "end_year": 1127},
        {"name_zh": "元代", "name_en": "Yuan Dynasty", "start_year": 1271, "end_year": 1368},
        {"name_zh": "清代", "name_en": "Qing Dynasty", "start_year": 1644, "end_year": 1912},
    ]
    dynasties = []
    for data in dynasties_data:
        d = Dynasty(**data)
        db.session.add(d)
        dynasties.append(d)
    db.session.flush()

    locations_data = [
        {"name_zh": "中国", "name_en": "China", "type": "country"},
        {"name_zh": "北京", "name_en": "Beijing", "type": "city"},
        {"name_zh": "武汉", "name_en": "Wuhan", "type": "city"},
        {"name_zh": "石家庄", "name_en": "Shijiazhuang", "type": "city"},
        {"name_zh": "兰州", "name_en": "Lanzhou", "type": "city"},
        {"name_zh": "台北", "name_en": "Taipei", "type": "city"},
        {"name_zh": "西安", "name_en": "Xi'an", "type": "city"},
    ]
    locations = []
    for data in locations_data:
        loc = Location(**data)
        db.session.add(loc)
        locations.append(loc)
    db.session.flush()

    user1 = User(
        username="admin",
        password_hash=generate_password_hash("123456"),
        email="admin@museum.com",
        nickname="管理员",
        status="active",
        source="app",
    )
    user2 = User(
        username="visitor",
        password_hash=generate_password_hash("123456"),
        email="visitor@museum.com",
        nickname="游客",
        status="active",
        source="app",
    )
    db.session.add(user1)
    db.session.add(user2)
    db.session.flush()

    admin_role = Role(name="super_admin", display_name="超级管理员", description="系统最高权限")
    user_role = Role(name="user", display_name="普通用户", description="普通注册用户")
    db.session.add(admin_role)
    db.session.add(user_role)
    db.session.flush()

    db.session.add(UserRole(user_id=user1.id, role_id=admin_role.id))
    db.session.add(UserRole(user_id=user2.id, role_id=user_role.id))

    artifacts_data = [
        {
            "object_id": "OBJ001", "title_zh": "后母戊鼎", "title_en": "Houmuwu Ding",
            "time_period": "商代晚期", "dynasty_id": dynasties[0].id, "type": "青铜器",
            "material": "青铜", "museum_id": museums[0].id, "location_id": locations[1].id,
            "detail_url": "http://www.chnmuseum.cn/houmuwu", "image_url": "/static/images/artifact_1.jpg",
            "image_path": "static/images/artifact_1.jpg",
            "description": "后母戊鼎，又称司母戊鼎，是商代晚期的青铜礼器，是已知中国古代最重的青铜器。鼎通体高133厘米、口长112厘米、口宽79.2厘米、壁厚6厘米，重达832.84千克。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ002", "title_zh": "四羊方尊", "title_en": "Four-Ram Square Zun",
            "time_period": "商代晚期", "dynasty_id": dynasties[0].id, "type": "青铜器",
            "material": "青铜", "museum_id": museums[0].id, "location_id": locations[1].id,
            "detail_url": "http://www.chnmuseum.cn/siyang", "image_url": "/static/images/artifact_2.jpg",
            "image_path": "static/images/artifact_2.jpg",
            "description": "四羊方尊是商代晚期的青铜礼器，是现存商代青铜方尊中最大的一件。尊的四角各塑一羊，造型雄奇，工艺精湛。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ003", "title_zh": "越王勾践剑", "title_en": "Sword of Goujian",
            "time_period": "春秋晚期", "dynasty_id": dynasties[2].id, "type": "兵器",
            "material": "青铜", "museum_id": museums[2].id, "location_id": locations[2].id,
            "detail_url": "http://www.hbww.org/goujian", "image_url": "/static/images/artifact_3.jpg",
            "image_path": "static/images/artifact_3.jpg",
            "description": "越王勾践剑是春秋晚期越国青铜器，出土于湖北江陵，剑身铸有越王勾践自作用剑的铭文，历经两千余年仍锋利无比。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ004", "title_zh": "清明上河图", "title_en": "Along the River During the Qingming Festival",
            "time_period": "北宋", "dynasty_id": dynasties[8].id, "type": "书画",
            "material": "绢本设色", "museum_id": museums[1].id, "location_id": locations[1].id,
            "detail_url": "https://www.dpm.org.cn/qingming", "image_url": "/static/images/artifact_4.jpg",
            "image_path": "static/images/artifact_4.jpg",
            "description": "清明上河图是北宋画家张择端所作的风俗画，描绘了北宋都城汴京的城市面貌和各阶层人民的生活状况，是中国十大传世名画之一。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ005", "title_zh": "唐三彩骆驼载乐俑", "title_en": "Tang Sancai Camel with Musicians",
            "time_period": "唐代", "dynasty_id": dynasties[7].id, "type": "陶器",
            "material": "陶器", "museum_id": museums[0].id, "location_id": locations[1].id,
            "detail_url": "http://www.chnmuseum.cn/tangsancai", "image_url": "/static/images/artifact_5.jpg",
            "image_path": "static/images/artifact_5.jpg",
            "description": "唐三彩骆驼载乐俑是唐代彩绘陶器的代表作，骆驼上载有乐舞俑，展现了盛唐时期丝绸之路上的繁荣景象。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ006", "title_zh": "金缕玉衣", "title_en": "Jade Burial Suit with Gold Thread",
            "time_period": "西汉", "dynasty_id": dynasties[5].id, "type": "玉器",
            "material": "玉、金丝", "museum_id": museums[3].id, "location_id": locations[3].id,
            "detail_url": "http://www.hebeimuseum.org/jade", "image_url": "/static/images/artifact_6.jpg",
            "image_path": "static/images/artifact_6.jpg",
            "description": "金缕玉衣是汉代皇帝和高级贵族死后穿用的殓服，用金丝将玉片编缀而成，是汉代最高规格的葬服。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ007", "title_zh": "曾侯乙编钟", "title_en": "Bianzhong of Marquis Yi of Zeng",
            "time_period": "战国早期", "dynasty_id": dynasties[3].id, "type": "乐器",
            "material": "青铜", "museum_id": museums[2].id, "location_id": locations[2].id,
            "detail_url": "http://www.hbww.org/bianzhong", "image_url": "/static/images/artifact_7.jpg",
            "image_path": "static/images/artifact_7.jpg",
            "description": "曾侯乙编钟是战国早期曾国国君的大型礼乐重器，全套编钟共65件，是迄今发现的最大最完整的一套青铜编钟。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ008", "title_zh": "马踏飞燕", "title_en": "Galloping Horse Treading on a Flying Swallow",
            "time_period": "东汉", "dynasty_id": dynasties[6].id, "type": "青铜器",
            "material": "青铜", "museum_id": museums[4].id, "location_id": locations[4].id,
            "detail_url": "http://www.gansumuseum.com/horse", "image_url": "/static/images/artifact_8.jpg",
            "image_path": "static/images/artifact_8.jpg",
            "description": "马踏飞燕又名铜奔马，是东汉时期的青铜器，造型矫健精美，马昂首嘶鸣，三足腾空，一足踏飞燕，是中国旅游标志。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ009", "title_zh": "翠玉白菜", "title_en": "Jadeite Cabbage",
            "time_period": "清代", "dynasty_id": dynasties[10].id, "type": "玉器",
            "material": "翡翠", "museum_id": museums[5].id, "location_id": locations[5].id,
            "detail_url": "https://www.npm.gov.tw/jadeite", "image_url": "/static/images/artifact_9.jpg",
            "image_path": "static/images/artifact_9.jpg",
            "description": "翠玉白菜是清代玉雕精品，利用翡翠天然的色泽分布雕刻而成，菜叶上还雕有螽斯和蝗虫，寓意多子多孙。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ010", "title_zh": "兵马俑", "title_en": "Terracotta Warriors",
            "time_period": "秦代", "dynasty_id": dynasties[4].id, "type": "陶器",
            "material": "陶", "museum_id": museums[6].id, "location_id": locations[6].id,
            "detail_url": "http://www.bmy.com.cn/terracotta", "image_url": "/static/images/artifact_10.jpg",
            "image_path": "static/images/artifact_10.jpg",
            "description": "秦始皇兵马俑是秦代陶塑艺术的杰出代表，被誉为世界第八大奇迹。每个陶俑面部表情各异，栩栩如生。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ011", "title_zh": "青花瓷瓶", "title_en": "Blue and White Porcelain Vase",
            "time_period": "元代", "dynasty_id": dynasties[9].id, "type": "瓷器",
            "material": "瓷器", "museum_id": museums[1].id, "location_id": locations[1].id,
            "detail_url": "https://www.dpm.org.cn/bluewhite", "image_url": "/static/images/artifact_11.jpg",
            "image_path": "static/images/artifact_11.jpg",
            "description": "元青花瓷瓶是元代景德镇窑烧制的青花瓷器，以钴蓝料在白色瓷胎上绘制纹饰，釉色白中泛青，花纹蓝中显翠。",
            "crawl_date": date.today(), "image_validated": 1,
        },
        {
            "object_id": "OBJ012", "title_zh": "大禹治水玉山", "title_en": "Jade Mountain of Yu the Great Taming the Flood",
            "time_period": "清代", "dynasty_id": dynasties[10].id, "type": "玉器",
            "material": "玉", "museum_id": museums[1].id, "location_id": locations[1].id,
            "detail_url": "https://www.dpm.org.cn/yumountain", "image_url": "/static/images/artifact_12.jpg",
            "image_path": "static/images/artifact_12.jpg",
            "description": "大禹治水玉山是清代乾隆年间的巨型玉雕，重达五千多公斤，是中国玉器宝库中用料最宏、运路最长、花时最久、费用最昂的玉雕工艺品。",
            "crawl_date": date.today(), "image_validated": 1,
        },
    ]

    for data in artifacts_data:
        artifact = Artifact(**data)
        db.session.add(artifact)

    violation_types_data = [
        {"type_code": "spam_comment", "type_name": "垃圾评论", "severity_level": 1, "default_penalty": "warning", "description": "发布无关内容、广告等"},
        {"type_code": "inappropriate_content", "type_name": "不当内容", "severity_level": 2, "default_penalty": "temp_ban", "description": "发布色情、暴力、侮辱性内容"},
        {"type_code": "fake_identity", "type_name": "虚假身份", "severity_level": 2, "default_penalty": "temp_ban", "description": "使用虚假身份或冒用他人身份"},
        {"type_code": "copyright_violation", "type_name": "版权侵权", "severity_level": 3, "default_penalty": "permanent_ban", "description": "上传未经授权的内容"},
        {"type_code": "malicious_attack", "type_name": "恶意攻击", "severity_level": 4, "default_penalty": "permanent_ban", "description": "恶意攻击系统或其他用户"},
        {"type_code": "frequent_operation", "type_name": "频繁操作", "severity_level": 1, "default_penalty": "warning", "description": "短时间内频繁操作，疑似机器行为"},
        {"type_code": "illegal_upload", "type_name": "违规上传", "severity_level": 2, "default_penalty": "temp_ban", "description": "上传不符合规范的文件"},
    ]
    for data in violation_types_data:
        vt = ViolationType(**data)
        db.session.add(vt)

    db.session.commit()
    print("数据库初始化完成，已添加示例数据")
