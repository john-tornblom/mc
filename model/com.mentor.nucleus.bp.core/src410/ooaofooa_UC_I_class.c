/*----------------------------------------------------------------------------
 * File:  ooaofooa_UC_I_class.c
 *
 * Class:       Include  (UC_I)
 * Component:   ooaofooa
 *
 * your copyright statement can go here (from te_copyright.body)
 *--------------------------------------------------------------------------*/

#include "sys_sys_types.h"
#include "LOG_bridge.h"
#include "POP_bridge.h"
#include "T_bridge.h"
#include "ooaofooa_classes.h"

/*
 * Instance Loader (from string data).
 */
Escher_iHandle_t
ooaofooa_UC_I_instanceloader( Escher_iHandle_t instance, const c_t * avlstring[] )
{
  Escher_iHandle_t return_identifier = 0;
  ooaofooa_UC_I * self = (ooaofooa_UC_I *) instance;
  /* Initialize application analysis class attributes.  */
  self->Assoc_ID = (Escher_iHandle_t) Escher_atoi( avlstring[ 1 ] );
  {i_t i = avlstring[ 2 + 1 ] - avlstring[ 2 ];
  self->Descrip = ( i > 0 ) ? (c_t *) Escher_malloc( i ) : "";
  while ( --i >= 0 ) { self->Descrip[ i ] = avlstring[ 2 ][ i ]; }
  }
  return return_identifier;
}

/*
 * Select any where using referential/identifying attribute set.
 * If not_empty, relate this instance to the selected instance.
 */
void ooaofooa_UC_I_batch_relate( Escher_iHandle_t instance )
{
  ooaofooa_UC_I * ooaofooa_UC_I_instance = (ooaofooa_UC_I *) instance;
  ooaofooa_UC_UCA * ooaofooa_UC_UCArelated_instance1 = ooaofooa_UC_UCA_AnyWhere1( ooaofooa_UC_I_instance->Assoc_ID );
  if ( ooaofooa_UC_UCArelated_instance1 ) {
    ooaofooa_UC_I_R1210_Link( ooaofooa_UC_UCArelated_instance1, ooaofooa_UC_I_instance );
  }
}


/*
 * RELATE UC_UCA TO UC_I ACROSS R1210
 */
void
ooaofooa_UC_I_R1210_Link( ooaofooa_UC_UCA * supertype, ooaofooa_UC_I * subtype )
{
  /* Use TagEmptyHandleDetectionOn() to detect empty handle references.  */
  subtype->Assoc_ID = supertype->Assoc_ID;
  /* Optimized linkage for UC_I->UC_UCA[R1210] */
  subtype->UC_UCA_R1210 = supertype;
  /* Optimized linkage for UC_UCA->UC_I[R1210] */
  supertype->R1210_subtype = subtype;
  supertype->R1210_object_id = ooaofooa_UC_I_CLASS_NUMBER;
}


/*
 * UNRELATE UC_UCA FROM UC_I ACROSS R1210
 */
void
ooaofooa_UC_I_R1210_Unlink( ooaofooa_UC_UCA * supertype, ooaofooa_UC_I * subtype )
{
  /* Use TagEmptyHandleDetectionOn() to detect empty handle references.  */
  subtype->UC_UCA_R1210 = 0;
  supertype->R1210_subtype = 0;
  supertype->R1210_object_id = 0;
}


/*
 * Dump instances in SQL format.
 */
void
ooaofooa_UC_I_instancedumper( Escher_iHandle_t instance )
{
  ooaofooa_UC_I * self = (ooaofooa_UC_I *) instance;
  printf( "INSERT INTO UC_I VALUES ( %ld,'%s' );\n",
    ((long)self->Assoc_ID & ESCHER_IDDUMP_MASK),
    self->Descrip );
}
/*
 * Statically allocate space for the instance population for this class.
 * Allocate space for the class instance and its attribute values.
 * Depending upon the collection scheme, allocate containoids (collection
 * nodes) for gathering instances into free and active extents.
 */
static Escher_SetElement_s ooaofooa_UC_I_container[ ooaofooa_UC_I_MAX_EXTENT_SIZE ];
static ooaofooa_UC_I ooaofooa_UC_I_instances[ ooaofooa_UC_I_MAX_EXTENT_SIZE ];
Escher_Extent_t pG_ooaofooa_UC_I_extent = {
  {0,0}, {0,0}, &ooaofooa_UC_I_container[ 0 ],
  (Escher_iHandle_t) &ooaofooa_UC_I_instances,
  sizeof( ooaofooa_UC_I ), 0, ooaofooa_UC_I_MAX_EXTENT_SIZE
  };


