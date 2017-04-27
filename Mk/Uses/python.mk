# Handle dependency requirements on python and setuptools
#
# Feature:	python
# Usage:	USES=python
# Valid ARGS:	(py27 or py34 or py35), build
#
# --------------------------------------
# Variables which can be set by the port
# --------------------------------------
#
# PYSETUP		Name of the setup script used by the distutils package
#			default: setup.py
# PYDISTUTILS_CONFIGURE_TARGET
#			Pass this command to distutils on configure stage.
#			default: config
# PYDISTUTILS_BUILD_TARGET
#			Pass this command to distutils on build stage.
#			default: build
# PYDISTUTILS_INSTALL_TARGET
#			Pass this command to distutils on install stage.
#			default: install
# PYDISTUTILS_CONFIGUREARGS
#			Arguments to config with distutils.
#			default: <empty>
# PYDISTUTILS_BUILDARGS
#			Arguments to build with distutils.
#			default: <empty>
# PYDISTUTILS_INSTALLARGS
#			Arguments to install with distutils.
#			default: refer below
#
# --------------------------------------
# Readonly variables
# --------------------------------------
# PYTHON_CMD		Python's command line file name, including version
#			default: ${LOCALBASE}/bin/python${PYTHON_VER}
# PYTHON_REL		The release number of the chosen Python interpreter
#			without dots, e.g. 2706, 3401, ...
# PYTHON_SUFFIX		The major-minor release number of the chosen Python
#			interpreter without dots, e.g. 27, 34, ...
# PYTHON_MAJOR_VER	The major release version of the chosen Python
#			interpreter, e.g. 2, 3, ...
# PYTHON_VER		The major-minor release version of the chosen Python
#			interpreter, e.g. 2.7, 3.4, ...
# PYTHON_ABIVER		Additional ABI flags set by the chosen Python
#			interpreter, e.g. md
# PYTHON_INCLUDEDIR	Location of the Python include files.
#			default: ${PYTHONBASE}/include/python${PYTHON_VER}
# PYTHON_LIBDIR		Base of the python library tree
#			default: ${PYTHONBASE}/lib/python${PYTHON_VER}
# PYTHON_SITELIBDIR	Location of the site-packages tree
#			default: ${PYTHON_LIBDIR}/site-packages
# PYTHON_PLATFORM	Python's idea of the OS release.
#			This is faked with ${OPSYS} and ${OSREL} until we
#			find out how to delay defining a variable until
#			after a certain target has been built.
#
# --------------------------------------
# Package list entries
# --------------------------------------
#	PYTHON_INCLUDEDIR=${PYTHONPREFIX_INCLUDEDIR:S;${PREFIX}/;;}
#	PYTHON_LIBDIR=${PYTHONPREFIX_LIBDIR:S;${PREFIX}/;;}
#	PYTHON_PLATFORM=${PYTHON_PLATFORM}
#	PYTHON_PYOEXTENSION=${PYTHON_PYOEXTENSION}
#	PYTHON_SITELIBDIR=${PYTHONPREFIX_SITELIBDIR:S;${PREFIX}/;;}
#	PYTHON_SUFFIX=${PYTHON_SUFFIX}
#	PYTHON_VER=${PYTHON_VER}
#	PYTHON_VERSION=python${PYTHON_VER}
#	PYTHON2=<blank>/"@comment "
#	PYTHON3=<blank>/"@comment "

.if !defined(_INCLUDE_USES_PYTHON_MK)
_INCLUDE_USES_PYTHON_MK=	yes

# ------------------------------------------------------
# Incorporated in ravenadm
# ------------------------------------------------------
# BUILDRUN_DEPENDS+=	pythonXX:single:standard
# BUILDRUN_DEPENDS+=	python-setuptools:single:pyXX
# ------------------------------------------------------

.  if !empty(python_ARGS:Mpy35)
_PYTHON_VERSION=	3.5
.  elif !empty(python_ARGS:Mpy34)
_PYTHON_VERSION=	3.4
.  elif !empty(python_ARGS:Mpy27)
_PYTHON_VERSION=	2.7
.  else
_PYTHON_VERSION=	${PYTHON3_DEFAULT}
.  endif

PYTHON_VER=		${_PYTHON_VERSION}
PYTHON_SUFFIX=		${_PYTHON_VERSION:S/.//g}
PYTHON_MAJOR_VER=	${PYTHON_VER:R}
PYTHON_REL=		${PYTHON_${_PYTHON_VERSION}_VERSION:S/.//}
PYTHON_CMD=		${LOCALBASE}/bin/python${PYTHON_VER}

PYTHON_ABIVER:=		# empty (unset or python2.7)
.  if ${PYTHON_VER:N2.7}
.    if exists(${PYTHON_CMD}-config)
PYTHON_ABIVER!=		${PYTHON_CMD}-config --abiflags
.    endif
.  endif

PYTHON_PLATFORM=	${OPSYS:tl}${MAJOR:R}
PYTHON_INCLUDEDIR=	${LOCALBASE}/include/python${PYTHON_VER}${PYTHON_ABIVER}
PYTHON_LIBDIR=		${LOCALBASE}/lib/python${PYTHON_VER}
PYTHON_SITELIBDIR=	${PYTHON_LIBDIR}/site-packages

# PEP 0488 (https://www.python.org/dev/peps/pep-0488/)
.  if ${PYTHON_REL} < 3500
PYTHON_PYOEXTENSION=	pyo
.  else
PYTHON_PYOEXTENSION=	opt-1.pyc
.  endif

# --------------------------------------
# distutils support
# --------------------------------------

# Used for recording the installed files.
_PYTHONPKGLIST=		${WRKDIR}/.PLIST.pymodtmp

PYSETUP?=		setup.py
PYDISTUTILS_SETUP=	-c "import sys; import setuptools; \
	__file__='${PYSETUP}'; sys.argv[0]='${PYSETUP}'; \
	exec(compile(open(__file__, 'rb').read().replace(b'\\r\\n', b'\\n'), __file__, 'exec'))"

PYDISTUTILS_CONFIGURE_TARGET?=	config
PYDISTUTILS_CONFIGUREARGS?=	# empty
PYDISTUTILS_BUILD_TARGET?=	build
PYDISTUTILS_BUILDARGS?=		# empty
PYDISTUTILS_INSTALL_TARGET?=	install
PYDISTUTILS_INSTALLARGS?=	--record ${_PYTHONPKGLIST} -c -O1 --prefix=${PREFIX} \
				--single-version-externally-managed \
				--root=${STAGEDIR}
PYDISTUTILS_EGGINFO?=		${NAMEBASE:C/[^A-Za-z0-9.]+/_/g}-${VERSION:C/[^A-Za-z0-9.]+/_/g}-py${PYTHON_VER}.egg-info
PYDISTUTILS_EGGINFODIR=		${STAGEDIR}${PYTHON_SITELIBDIR}

MAKE_ENV+=	LDSHARED="${CC} -shared" \
		PYTHONDONTWRITEBYTECODE= \
		PYTHONOPTIMIZE=

CONFIGURE_ENV+=	PYTHON="${PYTHON_CMD}"

PLIST_SUB+=	PYTHON_INCLUDEDIR=${PYTHON_INCLUDEDIR:S;${PREFIX}/;;} \
		PYTHON_LIBDIR=${PYTHON_LIBDIR:S;${PREFIX}/;;} \
		PYTHON_PLATFORM=${PYTHON_PLATFORM} \
		PYTHON_PYOEXTENSION=${PYTHON_PYOEXTENSION} \
		PYTHON_SITELIBDIR=${PYTHON_SITELIBDIR:S;${PREFIX}/;;} \
		PYTHON_SUFFIX=${PYTHON_SUFFIX} \
		PYTHON_VER=${PYTHON_VER} \
		PYTHON_VERSION=python${PYTHON_VER} \
		PYTHON_MAJOR_VER=${PYTHON_MAJOR_VER}

.if ${PYTHON_MAJOR_VER:M3}
PLIST_SUB+=	PYTHON3="" PYTHON2="@comment "
.else
PLIST_SUB+=	PYTHON2="" PYTHON3="@comment "
.endif

# By default CMake picks up the highest available version of Python package.
# Enforce the version required by the port or the default.

CMAKE_ARGS+=	-DPython_ADDITIONAL_VERSIONS=${PYTHON_VER}

.  if exists(${PYDISTUTILS_SETUP})

POST_PLIST_TARGET+=	setuptools-autolist

setuptools-autolist:
	@(cd ${STAGEDIR}${PREFIX} && ${FIND} lib bin \
	\( -type f -o -type l \) 2>/dev/null | ${SORT}) \
	>> ${WRKDIR}/.manifest.single.mktmp


.    if !target(do-configure) && !defined(HAS_CONFIGURE) && !defined(GNU_CONFIGURE)
do-configure:
	@(cd ${BUILD_WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${PYTHON_CMD} ${PYDISTUTILS_SETUP} ${PYDISTUTILS_CONFIGURE_TARGET} ${PYDISTUTILS_CONFIGUREARGS})
.    endif

.    if !target(do-build)
do-build:
	@(cd ${BUILD_WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${PYTHON_CMD} ${PYDISTUTILS_SETUP} ${PYDISTUTILS_BUILD_TARGET} ${PYDISTUTILS_BUILDARGS})
.    endif

.    if !target(do-install)
do-install:
	@(cd ${INSTALL_WRKSRC}; ${SETENV} ${MAKE_ENV} \
		${PYTHON_CMD} ${PYDISTUTILS_SETUP} ${PYDISTUTILS_INSTALL_TARGET} ${PYDISTUTILS_INSTALLARGS})
.    endif
.  endif

.endif	# _INCLUDE_USES_PYTHON_MK
