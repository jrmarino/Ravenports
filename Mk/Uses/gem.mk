# Support rubygem packages
#
# Feature:	gem
# Usage:	USES=gem
# Valid ARGS:	skiplist (Don't generate package list automatically)
#               v23      (requires Ruby 2.3)
#               v24      (requires Ruby 2.4) (implicit)

.if !defined(_INCLUDE_USES_GEM_MK)
_INCLUDE_USES_GEM_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILDRUN_DEPENDS+=	ruby-rubygems:single:v2[34]
# -----------------------------------------------

.  if ${gem_ARGS} == "v23"
GEMS_BASE_DIR=	lib/ruby/gems/2.3
RUBYGEMBIN=	${LOCALBASE}/bin/gem23
USING_RUBY=	2.3
.  else
GEMS_BASE_DIR=	lib/ruby/gems/2.4
RUBYGEMBIN=	${LOCALBASE}/bin/gem24
USING_RUBY=	2.4
.  endif

INSTALL_REQ_TOOLCHAIN=	yes

GEMS_DIR=	${GEMS_BASE_DIR}/gems
DOC_DIR=	${GEMS_BASE_DIR}/doc
CACHE_DIR=	${GEMS_BASE_DIR}/cache
SPEC_DIR=	${GEMS_BASE_DIR}/specifications
EXT_DIR=	${GEMS_BASE_DIR}/extensions
GEM_NAME?=	${NAMEBASE:C/^ruby-//}-${VERSION}
GEM_LIB_DIR=	${GEMS_DIR}/${GEM_NAME}
GEM_DOC_DIR=	${DOC_DIR}/${GEM_NAME}
GEM_SPEC=	${SPEC_DIR}/${GEM_NAME}.gemspec
GEM_CACHE=	${CACHE_DIR}/${GEM_NAME}.gem
GEMSPEC=	${NAMEBASE:C/^ruby-//}.gemspec
GEMFILE=	${DISTFILE_1:S/:main//}

GEM_ENV+=	RB_USER_INSTALL=1 \
		LANG=en_US.UTF-8 \
		LC_ALL=en_US.UTF-8 \
		HOME=/tmp

PLIST_SUB+=	PORTVERSION="${VERSION}" \
		GEMS_BASE_DIR="${GEMS_BASE_DIR}" \
		GEMS_DIR="${GEMS_DIR}" \
		DOC_DIR="${DOC_DIR}" \
		CACHE_DIR="${CACHE_DIR}" \
		SPEC_DIR="${SPEC_DIR}" \
		EXT_DIR="${EXT_DIR}" \
		GEM_NAME="${GEM_NAME}" \
		GEM_LIB_DIR="${GEM_LIB_DIR}" \
		GEM_DOC_DIR="${GEM_DOC_DIR}" \
		GEM_SPEC="${GEM_SPEC}" \
		GEM_CACHE="${GEM_CACHE}" \

RUBYGEM_ARGS=	-l --no-update-sources \
		--install-dir ${STAGEDIR}${PREFIX}/${GEMS_BASE_DIR} \
		--ignore-dependencies \
		--bindir=${STAGEDIR}${PREFIX}/bin \
		--no-rdoc --no-ri

RUBY_SB_ARGS=	-e "1s|^\#![[:space:]]*/usr/bin/env ruby\([[:space:]]\)|\#!${LOCALBASE}/bin/ruby${USING_RUBY:S/.//}\1|"
RUBY_SB_ARGS+=	-e "1s|^\#![[:space:]]*/usr/bin/env ruby$$|\#!${LOCALBASE}/bin/ruby${USING_RUBY:S/.//}|"

.  if !target(do-extract)
do-extract:
	@${SETENV} ${GEM_ENV} ${RUBYGEMBIN} unpack --target=${WRKDIR} \
		${DISTDIR}/${DIST_SUBDIR}/${GEMFILE}
	@(cd ${BUILD_WRKSRC} && \
	    if ! ${SETENV} ${GEM_ENV} ${RUBYGEMBIN} spec --ruby \
		${DISTDIR}/${DIST_SUBDIR}/${GEMFILE} > ${GEMSPEC} ; then \
		${ECHO_MSG} "===> Extraction failed unexpectedly."; \
		${FALSE}; \
	    fi)
.  endif

.  if !target(do-build)
do-build:
	@(cd ${BUILD_WRKSRC} && \
	    if ! ${SETENV} ${GEM_ENV} ${RUBYGEMBIN} build --force ${GEMSPEC} ; then \
		${ECHO_MSG} "===> Compilation failed unexpectedly."; \
		${FALSE}; \
	    fi)
.  endif

.  if !target(do-install)
_USES_install+= 780:post-install-gem

do-install:
	(cd ${BUILD_WRKSRC} && ${SETENV} ${GEM_ENV} \
		${RUBYGEMBIN} install ${RUBYGEM_ARGS} ${GEMFILE} -- --build-args ${CONFIGURE_ARGS})
	${RM} -r ${STAGEDIR}${PREFIX}/${GEMS_BASE_DIR}/build_info/
	${FIND} ${STAGEDIR}${PREFIX}/${GEMS_BASE_DIR} -type f -name '*.so' -exec ${STRIP_CMD} {} +
	${FIND} ${STAGEDIR}${PREFIX}/${GEMS_BASE_DIR} -type f \( -name mkmf.log -or -name gem_make.out \) -delete
	${RM} -r ${STAGEDIR}${PREFIX}/${GEM_LIB_DIR}/ext \
		${STAGEDIR}${PREFIX}/${CACHE_DIR} 2> /dev/null || ${TRUE}
	${RMDIR} ${STAGEDIR}${PREFIX}/${EXT_DIR} 2> /dev/null || ${TRUE}
	${RM} -r ${STAGEDIR}${PREFIX}/${DOC_DIR}

post-install-gem:
	${FIND} ${STAGEDIR}${PREFIX}/bin \
		\( -type f -o -type l \) > /tmp/rprograms
	${CP} /tmp/rprograms /tmp/rconflicts
	if [ -d ${STAGEDIR}${PREFIX}/lib/ruby/gems/*/gems/*/bin ]; then\
		${FIND} ${STAGEDIR}${PREFIX}/lib/ruby/gems/*/gems/*/bin \
		\( -type f -o -type l \) >> /tmp/rprograms;\
	fi
	if [ -s /tmp/rprograms ]; then\
	  ${SED} -i'' ${RUBY_SB_ARGS} `cat /tmp/rprograms`;\
	fi
.    if "${USING_RUBY}" != "${RUBY_DEFAULT}"
	while read thisfile; do \
	  mv $${thisfile} $${thisfile}${USING_RUBY:S/.//};\
	done < /tmp/rconflicts
.    endif
.  endif

.  if empty(gem_ARGS:Mskiplist)
_USES_install+=	950:gem-autoplist
gem-autoplist:
	@(cd ${STAGEDIR}${PREFIX} && \
	${FIND} lib bin share/man \
	\( -type f -o -type l \) 2>/dev/null | ${SORT}) \
	>> ${WRKDIR}/.manifest.single.mktmp
.  endif

.endif
