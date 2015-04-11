import os
from sets import Set
import csv
from collections import defaultdict

current_dir = '.'

experiments = defaultdict(lambda: defaultdict(lambda: -1))

def get_dirs(current_dir):
	dirs = filter(os.path.isdir, [os.path.join(current_dir, x) for x in os.listdir(current_dir)])
	return [x.split(os.sep)[-1] for x in dirs]

def get_subexperiment_type(dir_name):
	splitted = dir_name.split('_') 
	if len(splitted) != 4:
		return None

	return splitted[2] + '_' + splitted[3]

def get_dataset(dir_path):
	inner_dirs = get_dirs(dir_path)
	if len(inner_dirs) != 2:
		return None
	return filter(lambda x: x != 'axiomsets', inner_dirs)[0]

def get_best_result(dir_name):
	try :
		with open(os.path.join(dir_name, 'result'), 'rb') as result:
			line = next(result) 
			return line.split('\t')[1]
	except : 
		return None

types = Set()

for dir_name in get_dirs(current_dir):
	dir_path = os.path.join(current_dir, dir_name)
	subexperiment_type = get_subexperiment_type(dir_name)
	dataset = get_dataset(dir_path)
	result = get_best_result(dir_name)

	if not subexperiment_type or not dataset or not result:
		continue

	types.add(subexperiment_type)
	experiments[dataset][subexperiment_type] = result

types = sorted(list(types))

with open('results.csv', 'wb') as results:
	writer = csv.writer(results)
	writer.writerow(['dataset_name'] + types)
	for dataset in sorted(experiments):
		experiment = experiments[dataset]
		writer.writerow([dataset] + [experiment[x] for x in types])
