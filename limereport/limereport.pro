TARGET = limereport
TEMPLATE = lib

CONFIG += lib
CONFIG += dll
CONFIG += create_prl
CONFIG += link_prl

macx{
    CONFIG  -= dll
    CONFIG  += lib_bundle
    CONFIG  += plugin
}

DEFINES += LIMEREPORT_EXPORTS

EXTRA_FILES += \
    $$PWD/lrglobal.cpp \
    $$PWD/lrglobal.h \
    $$PWD/lrdatasourcemanagerintf.h \
    $$PWD/lrreportengine.h \
    $$PWD/lrscriptenginemanagerintf.h \
    $$PWD/lrcallbackdatasourceintf.h

include(limereport.pri)

unix {
    DESTDIR  = $${BUILD_DIR}/$${BUILD_TYPE}/lib
    for(FILE,EXTRA_FILES){
        QMAKE_POST_LINK += $$QMAKE_COPY $$quote($$FILE) $$quote($${DEST_INCLUDE_DIR}) $$escape_expand(\\n\\t)
    }
macx{
    QMAKE_POST_LINK += mkdir -p $$quote($${DESTDIR}/include) $$escape_expand(\\n\\t)
}
    QMAKE_POST_LINK += $(COPY_DIR) $$quote($${DEST_INCLUDE_DIR}*) $$quote($${DESTDIR}/include/)
}

win32 {
    EXTRA_FILES ~= s,/,\\,g
    BUILD_DIR ~= s,/,\\,g
    DESTDIR = $${BUILD_DIR}/$${BUILD_TYPE}/lib
    DEST_DIR = $$DESTDIR/include/
    DEST_DIR ~= s,/,\\,g
    DEST_INCLUDE_DIR ~= s,/,\\,g

    for(FILE,EXTRA_FILES){
        QMAKE_POST_LINK += $$QMAKE_COPY $$quote($$FILE) $$quote($${DEST_INCLUDE_DIR}) $$escape_expand(\\n\\t)
    }
    QMAKE_POST_LINK += $(COPY_DIR) $$quote($${DEST_INCLUDE_DIR}*) $$quote($${DEST_DIR})
}

contains(CONFIG,zint){
    message(zint)
    INCLUDEPATH += $$ZINT_PATH/backend $$ZINT_PATH/backend_qt4
    DEPENDPATH += $$ZINT_PATH/backend $$ZINT_PATH/backend_qt4
    LIBS += -L$${DESTDIR} -lQtZint
}

#######
####Automatically build required translation files (*.qm)

contains(CONFIG,build_translations){
    LANGUAGES = ru es_ES

    defineReplace(prependAll) {
        for(a,$$1):result += $$2$${a}$$3
        return($$result)
    }

    TRANSLATIONS = $$prependAll(LANGUAGES, $$TRANSLATIONS_PATH/limereport_,.ts)

    qtPrepareTool(LUPDATE, lupdate)
    ts.commands = $$LUPDATE $$PWD -ts $$TRANSLATIONS

    TRANSLATIONS_FILES =
    qtPrepareTool(LRELEASE, lrelease)
    for(tsfile, TRANSLATIONS) {
        qmfile = $$tsfile
        qmfile ~= s,.ts$,.qm,
        qm.commands += $$LRELEASE -removeidentical $$tsfile -qm $$qmfile $$escape_expand(\\n\\t)
        tmp_command = $$LRELEASE -removeidentical $$tsfile -qm $$qmfile $$escape_expand(\\n\\t)
        TRANSLATIONS_FILES += $$qmfile
    }
    qm.depends = ts
    OTHER_FILES += $$TRANSLATIONS
    QMAKE_EXTRA_TARGETS += qm ts
    POST_TARGETDEPS +=  qm
}

#### EN AUTOMATIC TRANSLATIONS


