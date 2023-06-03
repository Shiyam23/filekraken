// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_file_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarModuleOperationResultCollection on Isar {
  IsarCollection<IsarModuleOperationResult> get isarModuleOperationResults =>
      this.collection();
}

const IsarModuleOperationResultSchema = CollectionSchema(
  name: r'IsarModuleOperationResult',
  id: 1065877492409021095,
  properties: {
    r'dateTime': PropertySchema(
      id: 0,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'hashCode': PropertySchema(
      id: 1,
      name: r'hashCode',
      type: IsarType.long,
    ),
    r'isarFileResults': PropertySchema(
      id: 2,
      name: r'isarFileResults',
      type: IsarType.objectList,
      target: r'IsarFileOperationResult',
    ),
    r'operationType': PropertySchema(
      id: 3,
      name: r'operationType',
      type: IsarType.byte,
      enumMap: _IsarModuleOperationResultoperationTypeEnumValueMap,
    ),
    r'rootPath': PropertySchema(
      id: 4,
      name: r'rootPath',
      type: IsarType.string,
    )
  },
  estimateSize: _isarModuleOperationResultEstimateSize,
  serialize: _isarModuleOperationResultSerialize,
  deserialize: _isarModuleOperationResultDeserialize,
  deserializeProp: _isarModuleOperationResultDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'IsarFileOperationResult': IsarFileOperationResultSchema},
  getId: _isarModuleOperationResultGetId,
  getLinks: _isarModuleOperationResultGetLinks,
  attach: _isarModuleOperationResultAttach,
  version: '3.1.0+1',
);

int _isarModuleOperationResultEstimateSize(
  IsarModuleOperationResult object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.isarFileResults.length * 3;
  {
    final offsets = allOffsets[IsarFileOperationResult]!;
    for (var i = 0; i < object.isarFileResults.length; i++) {
      final value = object.isarFileResults[i];
      bytesCount += IsarFileOperationResultSchema.estimateSize(
          value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.rootPath.length * 3;
  return bytesCount;
}

void _isarModuleOperationResultSerialize(
  IsarModuleOperationResult object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateTime);
  writer.writeLong(offsets[1], object.hashCode);
  writer.writeObjectList<IsarFileOperationResult>(
    offsets[2],
    allOffsets,
    IsarFileOperationResultSchema.serialize,
    object.isarFileResults,
  );
  writer.writeByte(offsets[3], object.operationType.index);
  writer.writeString(offsets[4], object.rootPath);
}

IsarModuleOperationResult _isarModuleOperationResultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarModuleOperationResult(
    dateTime: reader.readDateTime(offsets[0]),
    id: id,
    isarFileResults: reader.readObjectList<IsarFileOperationResult>(
          offsets[2],
          IsarFileOperationResultSchema.deserialize,
          allOffsets,
          IsarFileOperationResult(),
        ) ??
        [],
    operationType: _IsarModuleOperationResultoperationTypeValueEnumMap[
            reader.readByteOrNull(offsets[3])] ??
        OperationType.extract,
    rootPath: reader.readString(offsets[4]),
  );
  return object;
}

P _isarModuleOperationResultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readObjectList<IsarFileOperationResult>(
            offset,
            IsarFileOperationResultSchema.deserialize,
            allOffsets,
            IsarFileOperationResult(),
          ) ??
          []) as P;
    case 3:
      return (_IsarModuleOperationResultoperationTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          OperationType.extract) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarModuleOperationResultoperationTypeEnumValueMap = {
  'extract': 0,
  'insert': 1,
  'create': 2,
  'rename': 3,
};
const _IsarModuleOperationResultoperationTypeValueEnumMap = {
  0: OperationType.extract,
  1: OperationType.insert,
  2: OperationType.create,
  3: OperationType.rename,
};

Id _isarModuleOperationResultGetId(IsarModuleOperationResult object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarModuleOperationResultGetLinks(
    IsarModuleOperationResult object) {
  return [];
}

void _isarModuleOperationResultAttach(
    IsarCollection<dynamic> col, Id id, IsarModuleOperationResult object) {
  object.id = id;
}

extension IsarModuleOperationResultQueryWhereSort on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QWhere> {
  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarModuleOperationResultQueryWhere on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QWhereClause> {
  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension IsarModuleOperationResultQueryFilter on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QFilterCondition> {
  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> hashCodeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> hashCodeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> hashCodeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashCode',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> hashCodeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> isarFileResultsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'isarFileResults',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> isarFileResultsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'isarFileResults',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> isarFileResultsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'isarFileResults',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> isarFileResultsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'isarFileResults',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> isarFileResultsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'isarFileResults',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> isarFileResultsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'isarFileResults',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> operationTypeEqualTo(OperationType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> operationTypeGreaterThan(
    OperationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> operationTypeLessThan(
    OperationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> operationTypeBetween(
    OperationType lower,
    OperationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rootPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
          QAfterFilterCondition>
      rootPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
          QAfterFilterCondition>
      rootPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rootPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rootPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterFilterCondition> rootPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rootPath',
        value: '',
      ));
    });
  }
}

extension IsarModuleOperationResultQueryObject on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QFilterCondition> {
  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
          QAfterFilterCondition>
      isarFileResultsElement(FilterQuery<IsarFileOperationResult> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'isarFileResults');
    });
  }
}

extension IsarModuleOperationResultQueryLinks on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QFilterCondition> {}

extension IsarModuleOperationResultQuerySortBy on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QSortBy> {
  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByOperationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByOperationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.desc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByRootPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rootPath', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> sortByRootPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rootPath', Sort.desc);
    });
  }
}

extension IsarModuleOperationResultQuerySortThenBy on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QSortThenBy> {
  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByHashCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashCode', Sort.desc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByOperationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByOperationTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationType', Sort.desc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByRootPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rootPath', Sort.asc);
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult,
      QAfterSortBy> thenByRootPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rootPath', Sort.desc);
    });
  }
}

extension IsarModuleOperationResultQueryWhereDistinct on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QDistinct> {
  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult, QDistinct>
      distinctByHashCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashCode');
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult, QDistinct>
      distinctByOperationType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationType');
    });
  }

  QueryBuilder<IsarModuleOperationResult, IsarModuleOperationResult, QDistinct>
      distinctByRootPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rootPath', caseSensitive: caseSensitive);
    });
  }
}

extension IsarModuleOperationResultQueryProperty on QueryBuilder<
    IsarModuleOperationResult, IsarModuleOperationResult, QQueryProperty> {
  QueryBuilder<IsarModuleOperationResult, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarModuleOperationResult, DateTime, QQueryOperations>
      dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<IsarModuleOperationResult, int, QQueryOperations>
      hashCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashCode');
    });
  }

  QueryBuilder<IsarModuleOperationResult, List<IsarFileOperationResult>,
      QQueryOperations> isarFileResultsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarFileResults');
    });
  }

  QueryBuilder<IsarModuleOperationResult, OperationType, QQueryOperations>
      operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationType');
    });
  }

  QueryBuilder<IsarModuleOperationResult, String, QQueryOperations>
      rootPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rootPath');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarFileOperationResultSchema = Schema(
  name: r'IsarFileOperationResult',
  id: -3837660698104967315,
  properties: {
    r'error': PropertySchema(
      id: 0,
      name: r'error',
      type: IsarType.byte,
      enumMap: _IsarFileOperationResulterrorEnumValueMap,
    ),
    r'fileSource': PropertySchema(
      id: 1,
      name: r'fileSource',
      type: IsarType.string,
    ),
    r'fileTarget': PropertySchema(
      id: 2,
      name: r'fileTarget',
      type: IsarType.string,
    ),
    r'operationType': PropertySchema(
      id: 3,
      name: r'operationType',
      type: IsarType.byte,
      enumMap: _IsarFileOperationResultoperationTypeEnumValueMap,
    ),
    r'resultType': PropertySchema(
      id: 4,
      name: r'resultType',
      type: IsarType.byte,
      enumMap: _IsarFileOperationResultresultTypeEnumValueMap,
    ),
    r'rootPath': PropertySchema(
      id: 5,
      name: r'rootPath',
      type: IsarType.string,
    )
  },
  estimateSize: _isarFileOperationResultEstimateSize,
  serialize: _isarFileOperationResultSerialize,
  deserialize: _isarFileOperationResultDeserialize,
  deserializeProp: _isarFileOperationResultDeserializeProp,
);

int _isarFileOperationResultEstimateSize(
  IsarFileOperationResult object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.fileSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileTarget;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rootPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _isarFileOperationResultSerialize(
  IsarFileOperationResult object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.error.index);
  writer.writeString(offsets[1], object.fileSource);
  writer.writeString(offsets[2], object.fileTarget);
  writer.writeByte(offsets[3], object.operationType.index);
  writer.writeByte(offsets[4], object.resultType.index);
  writer.writeString(offsets[5], object.rootPath);
}

IsarFileOperationResult _isarFileOperationResultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarFileOperationResult(
    error: _IsarFileOperationResulterrorValueEnumMap[
            reader.readByteOrNull(offsets[0])] ??
        ErrorType.other,
    fileSource: reader.readStringOrNull(offsets[1]),
    fileTarget: reader.readStringOrNull(offsets[2]),
    operationType: _IsarFileOperationResultoperationTypeValueEnumMap[
            reader.readByteOrNull(offsets[3])] ??
        OperationType.extract,
    resultType: _IsarFileOperationResultresultTypeValueEnumMap[
            reader.readByteOrNull(offsets[4])] ??
        ResultType.success,
    rootPath: reader.readStringOrNull(offsets[5]),
  );
  return object;
}

P _isarFileOperationResultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_IsarFileOperationResulterrorValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ErrorType.other) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (_IsarFileOperationResultoperationTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          OperationType.extract) as P;
    case 4:
      return (_IsarFileOperationResultresultTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ResultType.success) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _IsarFileOperationResulterrorEnumValueMap = {
  'invalidRootPath': 0,
  'invalidSource': 1,
  'invalidTarget': 2,
  'fileNotFound': 3,
  'pathNotFound': 4,
  'fileAlreadyExists': 5,
  'pathAlreadyExists': 6,
  'other': 7,
  'noPermission': 8,
  'none': 9,
};
const _IsarFileOperationResulterrorValueEnumMap = {
  0: ErrorType.invalidRootPath,
  1: ErrorType.invalidSource,
  2: ErrorType.invalidTarget,
  3: ErrorType.fileNotFound,
  4: ErrorType.pathNotFound,
  5: ErrorType.fileAlreadyExists,
  6: ErrorType.pathAlreadyExists,
  7: ErrorType.other,
  8: ErrorType.noPermission,
  9: ErrorType.none,
};
const _IsarFileOperationResultoperationTypeEnumValueMap = {
  'extract': 0,
  'insert': 1,
  'create': 2,
  'rename': 3,
};
const _IsarFileOperationResultoperationTypeValueEnumMap = {
  0: OperationType.extract,
  1: OperationType.insert,
  2: OperationType.create,
  3: OperationType.rename,
};
const _IsarFileOperationResultresultTypeEnumValueMap = {
  'success': 0,
  'fail': 1,
  'dryRun': 2,
};
const _IsarFileOperationResultresultTypeValueEnumMap = {
  0: ResultType.success,
  1: ResultType.fail,
  2: ResultType.dryRun,
};

extension IsarFileOperationResultQueryFilter on QueryBuilder<
    IsarFileOperationResult, IsarFileOperationResult, QFilterCondition> {
  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> errorEqualTo(ErrorType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'error',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> errorGreaterThan(
    ErrorType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'error',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> errorLessThan(
    ErrorType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'error',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> errorBetween(
    ErrorType lower,
    ErrorType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'error',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileSource',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileSource',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSource',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
          QAfterFilterCondition>
      fileSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileSource',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
          QAfterFilterCondition>
      fileSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileSource',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSource',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileSource',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileTarget',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileTarget',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileTarget',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
          QAfterFilterCondition>
      fileTargetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileTarget',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
          QAfterFilterCondition>
      fileTargetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileTarget',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileTarget',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> fileTargetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileTarget',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> operationTypeEqualTo(OperationType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> operationTypeGreaterThan(
    OperationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> operationTypeLessThan(
    OperationType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> operationTypeBetween(
    OperationType lower,
    OperationType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> resultTypeEqualTo(ResultType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resultType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> resultTypeGreaterThan(
    ResultType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resultType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> resultTypeLessThan(
    ResultType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resultType',
        value: value,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> resultTypeBetween(
    ResultType lower,
    ResultType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resultType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rootPath',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rootPath',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rootPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
          QAfterFilterCondition>
      rootPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rootPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
          QAfterFilterCondition>
      rootPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rootPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rootPath',
        value: '',
      ));
    });
  }

  QueryBuilder<IsarFileOperationResult, IsarFileOperationResult,
      QAfterFilterCondition> rootPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rootPath',
        value: '',
      ));
    });
  }
}

extension IsarFileOperationResultQueryObject on QueryBuilder<
    IsarFileOperationResult, IsarFileOperationResult, QFilterCondition> {}
