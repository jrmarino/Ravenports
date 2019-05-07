# On a per file basis, insert static functions to source to allow
# building on old solaris 10.
# Supports
#  - asprintf/vasprintf
#  - mkdtemp
#  - dirfd
#  - strnlen
#  - strndup
#
# Feature:     solaris-funcs
# Usage:       USES=solaris-funcs
# Valid ARGS:  none
#
# Used in conjunction with the following KEYWORDS
#
# SOL_FUNCTIONS      Format: function:path-to-file
#                    The path starts at $WRKSRC
#

.if !defined(_INCLUDE_USES_SOLFUNC_MK)
_INCLUDE_USES_SOLFUNC_MK=	yes

.  if "${OPSYS}" == "SunOS"
_USES_extract+=        810:insertsolfunc
.  endif

SOL_FUNC_ASPRINTF=	${SOL_FUNCTIONS:Masprintf\:*:C/.*://:O:u}
SOL_FUNC_MKDTEMP=	${SOL_FUNCTIONS:Mmkdtemp\:*:C/.*://:O:u}
SOL_FUNC_DIRFD=		${SOL_FUNCTIONS:Mdirfd\:*:C/.*://:O:u}
SOL_FUNC_STRNLEN=	${SOL_FUNCTIONS:Mstrnlen\:*:C/.*://:O:u}
SOL_FUNC_STRNDUP=	${SOL_FUNCTIONS:Mstrndup\:*:C/.*://:O:u}
SOL_UNIQUE=		${SOL_FUNCTIONS:C/.*://:O:u}

insertsolfunc:
	@${ECHO_MSG} "===>  Add static functions for solaris 10"
.for F in ${SOL_UNIQUE}
	@if [ -f "${WRKSRC}/${F}" ]; then \
	  ${MV} ${WRKSRC}/${F} ${WRKSRC}/${F}.solfunc ;\
	else \
          ${ECHO_MSG} "solaris-func issue: ${F} does not exist." ;\
	fi
.endfor
.for F in ${SOL_FUNC_ASPRINTF}
	@${ECHO_MSG} "====>  Insert asprint/vasprint to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh asprintf >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_MKDTEMP}
	@${ECHO_MSG} "====>  Insert mkdtemp to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh mkdtemp >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_DIRFD}
	@${ECHO_MSG} "====>  Insert dirfd to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh dirfd >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_STRNLEN}
	@${ECHO_MSG} "====>  Insert strnlen to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh strnlen >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_STRNDUP}
	@${ECHO_MSG} "====>  Insert strndup to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh strndup >> ${WRKSRC}/${F}
.endfor

.for F in ${SOL_UNIQUE}
	@${CAT} ${WRKSRC}/${F}.solfunc >> ${WRKSRC}/${F}
.endfor

.endif	# _INCLUDE_USES_SOLFUNC_MK