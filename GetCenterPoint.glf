#
# Copyright 2020 (c) Pointwise, Inc.
# All rights reserved.
#
# This sample Pointwise script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

#######################################################################
##
## Create DB Point at Center Point of Circular Curve Segment
##
## Allows you to choose a circular curve segment and locate the center 
## that circular curve segment.
##
## 1. Choose circular curve segment
## 2. Initiate script
## 3. DB point is created at center point location
##
#######################################################################

package require PWI_Glyph 3.18.3

## Return existing or create new group with the given name
proc getGroup { name } {
  if [catch {pw::Group getByName $name} group] {
    set group [pw::Group create]
    $group setName $name
    $group setEntityType "pw::DatabaseEntity"
  } elseif { [$group getEntityType] != "pw::DatabaseEntity" } {
    return -code error "Existing group is not a database group"
  }
  return $group
}

## Select entities
proc selectCurveEntities { } {

  # Define the selection mask (select connectors, DB curves, and/or source curves)
  set selectionMask [pw::Display createSelectionMask -requireConnector {} \
    -requireDatabase {Curves} -requireSource {Curves}]

  # Interactive selection
  pw::Display selectEntities -description "Select circular connector and/or DB curve..." \
    -selectionmask $selectionMask selectionArray

  # return a flattened array of connectors, database curves and source curves
  return [join [list $selectionArray(Connectors) $selectionArray(Databases) $selectionArray(Sources)]]
}

## Get center points and create DB point
proc createCenterPoints { ents group } {
  foreach ent $ents {

    foreach segment [$ent getSegments] {
      if [$segment isOfType pw::SegmentCircle] {
        # Get center point
        if [catch {$segment getCenterPoint} centerPoint] {
          return -code error "Could not get the center of the circular arc in \"[$ent getName]\""
        }

        # Create DB point
        set dbPoint [pw::Point create]
        $dbPoint setPoint $centerPoint

        # Make the DB point red
        $dbPoint setRenderAttribute ColorMode Entity
        $dbPoint setColor "#FF0000"

        # Add the DB point to the group
        $group addEntity $dbPoint
      }
    }
  }
}


# --------------------------------------------------------------------------
# Main script body

if [pw::Application isInteractive] {
  # Get center points and create DB point for all selected curve entities
  createCenterPoints [selectCurveEntities] [getGroup "Centers"]
} else {
  puts "This script can only be run interactively."
}

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE
# FAULT OR NEGLIGENCE OF POINTWISE.
#
