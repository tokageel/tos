#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
research.py

複数のXMLファイルから、ざっくりと構造を把握するためのスクリプト.
"""

import xml.etree.ElementTree as ET
import os
import sys


class XmlFormatResearch(object):
    """
    あらかじめ指定したタグについて、複数のXMLファイルから解析を行うクラス.
    """

    def __init__(self, tag):
        """
        解析対象のタグを指定してインスタンスを生成する.
        :param tag: 解析対象のタグ.
        """
        self.target_tag = tag
        self.__element_count = 0
        self.__attributes = {}
        self.children = {}

    def parse_xml_file(self, xml_file):
        """
        指定したXMLファイルをパーズして属性と雇用その情報を収集する.
        :param xml_file: XMLファイルへのパス.
        :return XMLの構文解析に失敗した場合はエラーオブジェクトを返す. それ以外の場合はnull.
        """
        try:
            tree = ET.parse(xml_file)
        except ET.ParseError as err:
            # そもそもXMLとして読み込めないファイル
            return err

        for element in tree.getroot().iter(self.target_tag):
            self.__element_count += 1
            # 属性
            for key in element.attrib.keys():
                v = element.attrib[key]
                if v is not None:
                    self.__attributes.setdefault(key, {})
                    self.__attributes[key].setdefault('count', 0)
                    self.__attributes[key]['count'] += 1
                    self.__attributes[key].setdefault('max_length', 0)
                    self.__attributes[key]['max_length'] = max(self.__attributes[key]['max_length'], len(v))
                    self.__attributes[key].setdefault('values', set())
                    self.__attributes[key]['values'].add(v)

            # 子要素
            for e in element:
                key = e.tag
                self.children.setdefault(key, {})
                self.children[key].setdefault('count', 0)
                self.children[key]['count'] += 1

    def print_result(self):
        """
        解析結果を標準出力へ出力する.
        :return:
        """
        print('-' * 10)
        print('{} 出現回数={}'
              .format(self.target_tag, self.__element_count))
        print('  属性: {}個'.format(len(self.__attributes.keys())))
        for k in self.__attributes.keys():
            v = self.__attributes[k]
            print('    {}: 出現回数={} ({:.2f}%) 最大長:{} パターン:{}'.format(
                k,
                v['count'],
                (100.0 * v['count'] / self.__element_count),
                v['max_length'],
                len(v['values']))
            )
            for value in list(v['values'])[:10]:
                print('      ' + value)
            if len(v['values']) > 10:
                print('      ...')

        print('  子要素: {}個'.format(len(self.children.keys())))
        for k in self.children.keys():
            v = self.children[k]['count']
            print('    {}: 出現回数={} '.format(k, v))


def find_all_files(directory):
    """
    指定したディレクトリ配下のファイルを返す.
    :param directory: ディレクトリ.
    :return: ディレクトリ配下のファイル.
    """
    for root, dirs, files in os.walk(directory, followlinks=True):
        for f in files:
            file_name, ext = os.path.splitext(f)
            if ext in ('.skn', '.xml'):
                yield os.path.join(root, f)


def print_usage():
    print('Usage: research.py [path to xml]')


if __name__ == '__main__':
    args = sys.argv
    root_dir = ''
    if len(args) == 2:
        root_dir = args[1]
    else:
        print_usage()
        sys.exit(1)
            
    root_tag = 'skinset'
    researches = list()
    researches.append(XmlFormatResearch(root_tag))
    results = list()
    while len(researches) > 0:
        # ファイルを走査
        for xmlFile in find_all_files(root_dir):
            for r in researches:
                r.parse_xml_file(xmlFile)

        # 抽出完了したタグは完了済みリストへ移す
        for e in researches:
            results.append(e)

        # 次の実行対象を構築する
        next_list = list()
        for done in researches:
            for child in done.children.keys():
                next_tag = child
                is_done = False
                # すでに結果リストに存在しているタグは次の実行対象に追加しない
                for e in results:
                    if e.target_tag == next_tag:
                        is_done = True
                        break
                # すでに次の実行対象に含まれている場合は次の実行対象に追加しない
                if not is_done:
                    for e in next_list:
                        if e.target_tag == next_tag:
                            is_done = True

                if not is_done:
                    next_list.append(XmlFormatResearch(next_tag))

        researches = next_list

    # 結果を出力
    for r in results:
        r.print_result()

    sys.exit(0)
