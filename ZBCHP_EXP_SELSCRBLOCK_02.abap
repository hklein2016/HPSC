*&---------------------------------------------------------------------*
*& Report  ZBCHP_EXP_SELSCRBLOCK_02
*&---------------------------------------------------------------------*
*& Examble Selection Screen – Expand 
*& Collapse Various Blocks
*& 7.0 bis XX kompatibel
*& Autor: Naveen Venkat Bhairava 
*& Link: http://zevolving.com/2014/07/selection-screen-expand-collapse-various-blocks/
*& Date: July 25th, 2014 at 6:39 am
*& Version: 1.0
*& Info: Code snippet to show how you can increase the user accessibility 
*& using the Expand Collapse of various blocks on the selection screen.
*& When selection screen has lot of elements, it makes more sense to hide 
*& them using the logical block. Users can Expand and collapse to view the 
*& fields – similar to Purchase Order Display ME23N.
*&---------------------------------------------------------------------*
REPORT ZBC_BSP_SELSCREEN_02.

TABLES: sscrfields.

DATA: v_erdat TYPE vbak-erdat,
      v_vkorg TYPE vbak-vkorg,
      v_auart TYPE vbak-auart,
      v_vbeln TYPE vbrk-vbeln.

CONSTANTS:  c_on  TYPE char1 VALUE '1',
            c_off TYPE char1 VALUE '0'.

CONSTANTS:
  BEGIN OF c_stat,
    open          TYPE char1 VALUE 'O',
    close         TYPE char1 VALUE 'C',
    close_w_val   TYPE char1 VALUE 'V',
  END   OF c_stat.

DATA: v_stat_so  TYPE char1.   " O - Open, C - Closed, V - Closed with Value.
DATA: v_stat_inv TYPE char1.   " O - Open, C - Closed, V - Closed with Value.

DATA: v_w_value  TYPE flag.

SELECTION-SCREEN: BEGIN OF BLOCK blk1 WITH FRAME TITLE text-t01.
PARAMETERS: p_kunnr TYPE kna1-kunnr. " OBLIGATORY.
SELECTION-SCREEN: END   OF BLOCK blk1.

* First block
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON (4) pb_so USER-COMMAND u_so.
SELECTION-SCREEN COMMENT 6(25) v_so.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN: BEGIN OF BLOCK blk2 WITH FRAME TITLE text-t02.
SELECT-OPTIONS: s_erdat FOR v_erdat MODIF ID so,
                s_vkorg FOR v_vkorg MODIF ID so,
                s_auart FOR v_auart MODIF ID so.
SELECTION-SCREEN: END   OF BLOCK blk2.

* Second block
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON (4) pb_inv USER-COMMAND u_inv.
SELECTION-SCREEN COMMENT 6(25) v_inv.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN: BEGIN OF BLOCK blk3 WITH FRAME TITLE text-t03.
SELECT-OPTIONS: si_erdat FOR v_erdat MODIF ID inv,
                si_vbeln FOR v_vbeln MODIF ID inv.
SELECTION-SCREEN: END   OF BLOCK blk3.

INITIALIZATION.
  v_so  = 'Sales Orders'.
  v_inv = 'Billing Documents'.
  PERFORM f_set_initial_icons.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'SO'.
        IF v_stat_so = c_stat-open.   "'O'.
          screen-active = c_on.    "'1'.
        ELSE.
          screen-active = c_off.   "'0'.
        ENDIF.
      WHEN 'INV'.
        IF v_stat_inv = c_stat-open.   "'O'.
          screen-active = c_on.
        ELSE.
          screen-active = c_off.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
  PERFORM f_set_icon USING v_stat_so CHANGING pb_so.
  PERFORM f_set_icon USING v_stat_inv CHANGING pb_inv.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'U_SO'.
      CLEAR v_w_value.
      IF s_erdat[] IS NOT INITIAL
      OR s_auart[] IS NOT INITIAL
      OR s_vkorg[] IS NOT INITIAL.
        v_w_value = 'X'.
      ENDIF.
      PERFORM f_set_stat USING v_w_value CHANGING v_stat_so.
    WHEN 'U_INV'.
      CLEAR v_w_value.
      IF  si_erdat[] IS NOT INITIAL
      OR  si_vbeln[] IS NOT INITIAL.
        v_w_value = 'X'.
      ENDIF.
      PERFORM f_set_stat USING v_w_value CHANGING v_stat_inv.
  ENDCASE.

*
FORM f_set_initial_icons.

  MOVE c_stat-close TO: v_stat_so,
                        v_stat_inv.

  PERFORM f_set_icon USING v_stat_so CHANGING pb_so.
  PERFORM f_set_icon USING v_stat_inv CHANGING pb_inv.

ENDFORM.                    "f_set_initial_icons
*
FORM f_set_icon USING       iv_stat TYPE char1
                CHANGING    cv_icon TYPE any.

  CASE iv_stat.
    WHEN c_stat-close.        cv_icon =  icon_data_area_expand.
    WHEN c_stat-open.         cv_icon =  icon_data_area_collapse.
    WHEN c_stat-close_w_val.  cv_icon =  icon_view_create. " ICON_status_best.
  ENDCASE.

ENDFORM.                    "f_set_icon
*
FORM f_set_stat USING    iv_w_value TYPE flag
                CHANGING cv_stat    TYPE char1.

  IF cv_stat = c_stat-open.
    IF iv_w_value IS INITIAL.
      cv_stat = c_stat-close.
    ELSE.
      cv_stat = c_stat-close_w_val.
    ENDIF.
  ELSEIF ( cv_stat = c_stat-close
       OR  cv_stat = c_stat-close_w_val ).
    cv_stat = c_stat-open.
  ENDIF.

ENDFORM.                    "f_set_Stat