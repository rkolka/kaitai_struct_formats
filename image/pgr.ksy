meta:
  id: pgr
  title: Ladybug Stream File Format
  file-extension: pgr
  endian: le
  imports:
  - /image/jpeg
seq:
  - id: magic1
    contents: PGRLADYBUGSTREAM
    doc: Identifies file as a Ladybug stream

  - id: stream_header
    type: stream_header_t

  - id: keyframe_offset_index_empty
    type: u4le
    repeat: expr
    repeat-expr: 512 - stream_header.num_index_entries

  - id: keyframe_offset_index_filled
    type: u4le
    repeat: expr
    repeat-expr: stream_header.num_index_entries

  - id: camera_configuration
    type: str
    encoding: UTF-8
    size: stream_header.len_configuration

  - id: padding1
    size: stream_header.ofs_frame - _io.pos

  - id: sentinel
    size: 0
    type: sentinel_t

instances:
  frames_i:
    pos: stream_header.ofs_frame
    type: frame_t
    size: _.len_image_data + stream_header.len_frame_header
    repeat: expr
    repeat-expr: stream_header.num_frames



types:

  frame_t:
    seq:
      - id: frame_header_placeholder
        size: _root.stream_header.len_frame_header
        doc: |
          It is unkown where amongst 512 bytes these values come:
          typedef struct LadybugImageHeader
          {
              unsigned int uiTemperature; 293    @0x040
              unsigned int uiHumidity;  53     @0x000
              unsigned int uiAirPressure;
              LadybugTriplet compass;
              LadybugTriplet accelerometer;
              LadybugTriplet gyroscope;
              bool needSoftwareAdjustment;
          } LadybugImageHeader;

      - id: timestamp
        type: timestamp_t
        doc:  Bits 0-6 (7), 7-19 (13), 20-31 (12)

      - id: reserved1
        size: 4
        doc: N/A

      - id: len_image_data
        type: u4be
        doc: The total data size of the this frame, including the padding block

      - id: image
        size: len_image_data - 12
        type: image_t

  image_t:
    seq:
      - id: reserved2
        size: 4
        #contents: [0,0,0,0]

      - id: magic2
        contents: [0xCA,0xFE,0xBA,0xBE]

      - id: version_number
        contents: [0x00,0x00,0x00,0x02]
        doc: should be 2

      - id: unix_time_sec
        type: u4be

      - id: unix_time_microsec
        type: u4be

      - id: seq_id
        type: u4be
        doc: image sequence number

      - id: horiz_rate
        type: u4be
        doc: Horizontal refresh rate

      - id: gain
        type: u4le
        repeat: expr
        repeat-expr: 6

      - id: white_balance
        type: u4be
        doc: Horizontal refresh rate

      - id: bayer_gain
        type: u4be
        doc: Horizontal refresh rate

      - id: bayer_map
        type: str
        size: 4
        encoding: UTF-8
        doc: FourCC

      - id: brightness
        type: u4be
        doc: Horizontal refresh rate

      - id: gamma
        type: u4be
        doc: Horizontal refresh rate

      - id: cam_serial_number
        type: u4be
        doc: Horizontal refresh rate

      - id: shutter
        type: u4be
        repeat: expr
        repeat-expr: 6

      - id: pps_data
        type: pps_data_t
        doc: Horizontal refresh rate

      - id: reserved3
        size: 24

      - id: reserved4
        size: 632

      - id: reserved5
        size: 52
        doc: NB! not 56

      - id: ofs_gps_data
        type: u4be

      - id: len_gps_data
        type: u4be

      - id: subimages
        size: _parent.len_image_data - 832
        type: subimages_t


  subimages_t:
    seq:
      - id: subimage
        type: subimage_t
        repeat: expr
        repeat-expr: 24

  subimage_t:
    seq:
      - id: ofs_body
        type: u4be
      - id: len_body
        type: u4be
    instances:
      get_ofs_body:
        value: _io.pos
      body:
        pos: ofs_body - 1024 + 192
        size: len_body
        type: jpeg


  sentinel_t:
    instances:
      sentinel_pos:
        value: _parent._io.pos

  stream_header_t:
    seq:
      - id: stream_version
        type: u4le
        doc: Stream file format version number (7)

      - id: frame_rate_obsolete
        type: u4le
        doc: Comperssor frame rate, not accurate (13)

      - id: serial_base_obsolete
        type: u4le
        doc: Ladybug base unit serial number (~ 13334444)

      - id: serial_head
        type: u4le
        doc: Ladybug head unit serial number (~ 13334444)

      - id: reserved1
        size: 104
        doc: Reserved space of 104 bytes

      - id: data_format
        type: u4le
        enum: ladybug_image_format
        doc: Image data format defined in ladybug.h (8 = color_sep_jpeg12)

      - id: resolution
        type: u4le
        enum: ladybug_sensor_resolution
        doc: Image resolution defined in ladybug.h (12 = r2464x2048)

      - id: stippled_format
        type: u4le
        enum: ladybug_stippled_format
        doc: Image Bayer pattern (3 = RGGB)

      - id: len_configuration
        type: u4le
        doc: Number of bytes of the configuration data (~ 338000)

      - id: num_frames
        type: u4le
        doc: N - Number of images in this stream file (not the whole stream!) (< 150)

      - id: num_index_entries
        type: u4le
        doc: Number of entries used in the index table ( < 5)

      - id: increment
        type: u4le
        doc: Interval value for Indexing the images (50)

      - id: ofs_frame
        type: u4le
        doc: Offset of the first frame data (~341000)

      - id: ofs_gps_summary
        type: u4le
        doc: Offset of GPS summary data block (0)

      - id: len_gps_summary
        type: u4le
        doc: Size of GPS summary data block (0)

      - id: len_frame_header
        type: u4le
        doc: Size of internal frame header. (512)

      - id: humidity_availability
        type: u4le
      - id: humidity_min
        type: u4le
      - id: humidity_max
        type: u4le

      - id: air_pressure_availability
        type: u4le
      - id: air_pressure_min
        type: u4le
      - id: air_pressure_max
        type: u4le

      - id: compass_availability
        type: u4le
      - id: compass_min
        type: u4le
      - id: compass_max
        type: u4le

      - id: accelerometer_availability
        type: u4le
      - id: accelerometer_min
        type: u4le
      - id: accelerometer_max
        type: u4le


      - id: gyroscope_availability
        type: u4le
      - id: gyroscope_min
        type: u4le
      - id: gyroscope_max
        type: u4le


      - id: frame_rate
        type: f4le
        doc: Actual frame rate, represented as a floating point value.

      - id: reserved2
        size: 780

  timestamp_t:
    seq:
    - id: cycle_second
      type: b7
      doc: seconds 0-127
    - id: cycle_count
      type: b13
      doc: 1/8000th of a cycle_second component
    - id: cycle_offset
      type: b12
      doc: 1/3072th of a cycle_count component

  pps_data_t:
    seq:
    - id: presence_of_feature
      type: b1
    - id: reserved1
      type: b23
    - id: gps_fix_quality
      type: b4
    - id: reserved2
      type: b2
    - id: gps_signal_valid
      type: b1
    - id: pps_signal_valid
      type: b1

enums:
  ladybug_image_format:
    1:  raw8
    2:  jpeg8
    3:  color_sep_raw8
    4:  color_sep_jpeg8
    5:  half_height_raw8
    6:  color_sep_half_height_jpeg8
    7:  raw16
    8:  color_sep_jpeg12
    9:  half_height_raw16
    10: color_sep_half_height_jpeg12
    11: raw12
    12: half_height_raw12
    13: num_dataformats
    14: any

  ladybug_sensor_resolution:
    4:  r1024x768
    8:  r1616x1232
    9:  r2448x2048
    11: any
    12: r2464x2048

  ladybug_stippled_format:
    0: bggr
    1: gbrg
    2: grbg
    3: rggb
    4: cam_default
