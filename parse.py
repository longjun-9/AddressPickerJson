#coding:utf8   #声明编码格式，不可注释
import sys
import json
import string
import os
reload(sys)
sys.setdefaultencoding('utf-8')

# 要转换的list.json的路径
filepath = r'/Users/Longjun/Desktop/list.json'
src_txt = open(filepath,'r').read()
jstr = json.loads(src_txt)

count = 0

def get_province_list(jstr):
	province_list = list()
	for key, val in jstr.items():
		if string.atoi(key)%10000 == 0:
			province_dict = dict()
			province_dict['code'] = key
			province_dict['name'] = val
			province_dict['cities'] = get_city_list(key)
			province_list.append(province_dict)
	# print 'length of province:'
	# print len(province_list)
	global count
	count += len(province_list)	
	return province_list


def get_city_list(prov_code):
	# 省编号
	tenThousandUnit = string.atoi(prov_code)/10000
	city_list = list()
	for key, val in jstr.items():
		# 指定的省
		if string.atoi(key)/10000 == tenThousandUnit:
			# 去掉省，筛选省下面的市和省直辖县
			if string.atoi(key)%10000 != 0:
				# 得到市
				if string.atoi(key)%100 == 0:
					city_dict = dict()
					city_dict['code'] = key
					city_dict['name'] = val
					country_list = get_country_list(key)
					# 对重庆进行特殊处理，重庆市辖县的子节点会归结到市辖区之下
					# 重庆市
					if string.atoi(key) == 500100:
						country_list.extend(get_country_list('500200'))
					city_dict['countries'] = country_list
					city_list.append(city_dict)
				else:
					# 得到省直辖县
					if string.atoi(key)/100*100 == tenThousandUnit*10000 + 90*100:
						city_dict = dict()
						city_dict['code'] = key
						city_dict['name'] = val
						city_list.append(city_dict)
					
	# print 'length of city:'
	# print len(city_list)
	global count
	count += len(city_list)				
	return city_list

def get_country_list(city_code):
	# 市编号
	hundredUnit = string.atoi(city_code)/100
	country_list = list()
	for key, val in jstr.items():
		if string.atoi(key)%100 != 0:
			# 县属于指定的市
			if string.atoi(key)/100 == hundredUnit:
				country_dict = dict()
				country_dict['code'] = key
				country_dict['name'] = val
				country_list.append(country_dict)
	# print 'length of country:'			
	# print len(country_list)	
	global count
	count += len(country_list)		
	return country_list


def store(data):
	# 输出的文件名
    with open('address.json', 'w') as json_file:
        json_file.write(json.dumps(data))



listArr = get_province_list(jstr)
# dic = get_city_list('110000')
# print listArr
print '生成json文件成功，路径为：' + os.getcwd() + '/data.json'
print '总的行政区划代码数量是：' + str(count)

store(listArr)
