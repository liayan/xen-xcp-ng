/*
 * Copyright (C) 2007 Oracle.  All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License v2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __PRINT_TREE_H__
#define __PRINT_TREE_H__

void btrfs_print_leaf(struct btrfs_root *root, struct extent_buffer *l);
void btrfs_print_tree(struct btrfs_root *root, struct extent_buffer *t, int follow);
void btrfs_print_key(struct btrfs_disk_key *disk_key);
void print_chunk(struct extent_buffer *eb, struct btrfs_chunk *chunk);
void print_extent_item(struct extent_buffer *eb, int slot, int metadata);
#endif
